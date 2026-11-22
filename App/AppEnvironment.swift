import SwiftUI
import Combine

/// Estado global de la aplicación LynxNodes
@MainActor
final class AppEnvironment: ObservableObject {
    @Published var isConfigured: Bool = false
    @Published var isBiometricallyUnlocked: Bool = true
    @Published var selectedTab: TabItem = .home
    @Published var hideTabBar: Bool = false
    @Published var cachedServers: [Server] = []
    @Published var favoriteServerIds: Set<String> = []
    
    private let favoritesKey = "lynxnodes_favorite_servers"
    
    enum TabItem: Int, CaseIterable, Identifiable {
        case home = 0
        case servers = 1
        case files = 2
        case settings = 3
        
        var id: Int { rawValue }
        
        var title: String {
            switch self {
            case .home: return "Inicio"
            case .servers: return "Servidores"
            case .files: return "Archivos"
            case .settings: return "Ajustes"
            }
        }
        
        var iconName: String {
            switch self {
            case .home: return "icon_home"
            case .servers: return "icon_servers"
            case .files: return "icon_files"
            case .settings: return "icon_settings"
            }
        }
    }
    
    init() {
        checkInitialState()
        loadFavorites()
    }
    
    func checkInitialState() {
        let hasKey = KeychainManager.shared.getApiKey() != nil
        self.isConfigured = hasKey
        
        if BiometricAuthManager.shared.isBiometricsEnabled && hasKey {
            self.isBiometricallyUnlocked = false
        } else {
            self.isBiometricallyUnlocked = true
        }
    }
    
    func unlockWithBiometrics() async -> Bool {
        let result = await BiometricAuthManager.shared.authenticate()
        switch result {
        case .success(let success):
            if success {
                self.isBiometricallyUnlocked = true
                HapticFeedback.success()
                return true
            }
            return false
        case .failure:
            HapticFeedback.error()
            return false
        }
    }
    
    func lockApp() {
        if BiometricAuthManager.shared.isBiometricsEnabled && isConfigured {
            isBiometricallyUnlocked = false
        }
    }
    
    func logout() {
        KeychainManager.shared.deleteApiKey()
        cachedServers.removeAll()
        isConfigured = false
        isBiometricallyUnlocked = true
        selectedTab = .home
        HapticFeedback.medium()
    }
    
    // MARK: - Favoritos
    
    private func loadFavorites() {
        if let array = UserDefaults.standard.stringArray(forKey: favoritesKey) {
            favoriteServerIds = Set(array)
        }
    }
    
    func toggleFavorite(serverId: String) {
        if favoriteServerIds.contains(serverId) {
            favoriteServerIds.remove(serverId)
        } else {
            favoriteServerIds.insert(serverId)
        }
        UserDefaults.standard.set(Array(favoriteServerIds), forKey: favoritesKey)
        HapticFeedback.light()
    }
    
    func isFavorite(serverId: String) -> Bool {
        favoriteServerIds.contains(serverId)
    }
}
