import SwiftUI
import Combine

/// ViewModel para la pantalla de Inicio / Dashboard general
@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var servers: [Server] = []
    @Published var errorMessage: String?
    @Published var serverStatsMap: [String: ServerStats] = [:]
    
    var runningCount: Int {
        servers.filter { $0.currentState == .running }.count
    }
    
    var startingCount: Int {
        servers.filter { $0.currentState == .starting }.count
    }
    
    var offlineCount: Int {
        servers.filter { $0.currentState == .offline || $0.currentState == .unknown }.count
    }
    
    var totalAllocatedMemoryMB: Int {
        servers.reduce(0) { $0 + max(0, $1.limits.memory) }
    }
    
    var totalAllocatedDiskMB: Int {
        servers.reduce(0) { $0 + max(0, $1.limits.disk) }
    }
    
    func refresh(appEnv: AppEnvironment) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched = try await PterodactylAPI.shared.getServers()
            self.servers = fetched
            appEnv.cachedServers = fetched
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "No se pudieron actualizar los servidores."
        }
        
        isLoading = false
    }
}
