import SwiftUI
import Combine

/// ViewModel para la pantalla de Inicio / Dashboard general (100% Datos Reales de la API)
@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isRefreshingSilently: Bool = false
    @Published var servers: [Server] = []
    @Published var errorMessage: String?
    @Published var isApiOnline: Bool = false
    
    private var refreshTask: Task<Void, Never>?
    
    var runningCount: Int {
        servers.filter { $0.currentState == .running }.count
    }
    
    var startingCount: Int {
        servers.filter { $0.currentState == .starting }.count
    }
    
    var offlineCount: Int {
        servers.filter { $0.currentState == .offline || $0.currentState == .stopping || $0.currentState == .unknown }.count
    }
    
    var totalAllocatedMemoryMB: Int {
        servers.reduce(0) { $0 + max(0, $1.limits.memory) }
    }
    
    var totalAllocatedDiskMB: Int {
        servers.reduce(0) { $0 + max(0, $1.limits.disk) }
    }
    
    var totalLiveUsedMemoryMB: Double {
        let bytes = servers.reduce(Int64(0)) { $0 + ($1.currentResources?.memoryBytes ?? 0) }
        return Double(bytes) / (1024.0 * 1024.0)
    }
    
    var totalLiveUsedDiskMB: Double {
        let bytes = servers.reduce(Int64(0)) { $0 + ($1.currentResources?.diskBytes ?? 0) }
        return Double(bytes) / (1024.0 * 1024.0)
    }
    
    func refresh(appEnv: AppEnvironment, showLoading: Bool = true) async {
        if showLoading && servers.isEmpty {
            isLoading = true
        } else {
            isRefreshingSilently = true
        }
        errorMessage = nil
        
        do {
            let fetched = try await PterodactylAPI.shared.getServersWithResources()
            self.servers = fetched
            appEnv.cachedServers = fetched
            self.isApiOnline = true
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            self.isApiOnline = false
        } catch {
            self.errorMessage = "No se pudieron actualizar los servidores."
            self.isApiOnline = false
        }
        
        isLoading = false
        isRefreshingSilently = false
    }
    
    func startAutoRefresh(appEnv: AppEnvironment) {
        stopAutoRefresh()
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 8_000_000_000) // 8 segundos
                if !Task.isCancelled {
                    await refresh(appEnv: appEnv, showLoading: false)
                }
            }
        }
    }
    
    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }
}
