import SwiftUI
import Combine

/// ViewModel para la pantalla de bienvenida y autenticación con Pterodactyl
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var panelUrl: String = PterodactylAPI.defaultBaseUrl
    @Published var apiKey: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var isSuccess: Bool = false
    
    init() {
        self.panelUrl = PterodactylAPI.shared.baseUrl
    }
    
    var isApiKeyFormatLikelyValid: Bool {
        let clean = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        return clean.hasPrefix("ptlc_") || clean.count >= 20
    }
    
    func testAndConnect(appEnv: AppEnvironment) async {
        let cleanKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanKey.isEmpty else {
            errorMessage = "Por favor, introduce tu Client API Key."
            showError = true
            HapticFeedback.warning()
            return
        }
        
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            // Guardar temporalmente la URL base
            PterodactylAPI.shared.baseUrl = panelUrl
            
            // Validar la clave contra GET /api/client
            let servers = try await PterodactylAPI.shared.validateConnection(baseUrl: panelUrl, apiKey: cleanKey)
            
            // Guardar en Keychain de forma segura
            KeychainManager.shared.saveApiKey(cleanKey)
            
            appEnv.cachedServers = servers
            appEnv.isConfigured = true
            isSuccess = true
            HapticFeedback.success()
            
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            self.showError = true
            HapticFeedback.error()
        } catch {
            self.errorMessage = "No se pudo establecer conexión con LynxNodes. Revisa tu clave y conexión."
            self.showError = true
            HapticFeedback.error()
        }
        
        isLoading = false
    }
}
