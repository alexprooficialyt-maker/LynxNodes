import SwiftUI
import Combine

/// ViewModel para la lista y filtrado de servidores (100% Datos Reales)
@MainActor
final class ServerListViewModel: ObservableObject {
    @Published var servers: [Server] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: ServerFilter = .all
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var refreshTask: Task<Void, Never>?
    
    enum ServerFilter: String, CaseIterable, Identifiable {
        case all = "Todos"
        case running = "En línea"
        case offline = "Apagados"
        
        var id: String { rawValue }
    }
    
    var filteredServers: [Server] {
        servers.filter { server in
            // Filtro por texto
            let matchesSearch = searchText.isEmpty ||
                server.name.localizedCaseInsensitiveContains(searchText) ||
                server.node.localizedCaseInsensitiveContains(searchText) ||
                server.id.localizedCaseInsensitiveContains(searchText)
            
            guard matchesSearch else { return false }
            
            // Filtro por categoría
            switch selectedFilter {
            case .all:
                return true
            case .running:
                return server.currentState == .running
            case .offline:
                return server.currentState == .offline || server.currentState == .stopping || server.currentState == .unknown
            }
        }
    }
    
    func loadServers(appEnv: AppEnvironment, forceRefresh: Bool = false) async {
        if !forceRefresh && !servers.isEmpty {
            return
        }
        
        if servers.isEmpty {
            isLoading = true
        }
        errorMessage = nil
        
        do {
            let fetched = try await PterodactylAPI.shared.getServersWithResources()
            self.servers = fetched
            appEnv.cachedServers = fetched
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Error al obtener servidores."
        }
        
        isLoading = false
    }
    
    func startAutoRefresh(appEnv: AppEnvironment) {
        stopAutoRefresh()
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 8_000_000_000)
                if !Task.isCancelled {
                    let fetched = (try? await PterodactylAPI.shared.getServersWithResources()) ?? []
                    if !fetched.isEmpty && !Task.isCancelled {
                        self.servers = fetched
                        appEnv.cachedServers = fetched
                    }
                }
            }
        }
    }
    
    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }
}
