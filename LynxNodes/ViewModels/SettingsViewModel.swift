import SwiftUI
import Combine

/// ViewModel para la configuración y preferencias de LynxNodes
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var panelUrl: String = ""
    @Published var maskedApiKey: String = ""
    @Published var newApiKeyInput: String = ""
    @Published var showApiKeyUpdateSheet: Bool = false
    @Published var isBiometricsEnabled: Bool = false
    @Published var consoleFontSize: Double = 12.0
    @Published var autoScrollDefault: Bool = true
    @Published var showLogoutAlert: Bool = false
    @Published var statusMessage: String?
    
    private let consoleFontSizeKey = "lynxnodes_console_font_size"
    private let autoScrollKey = "lynxnodes_console_autoscroll"
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        self.panelUrl = PterodactylAPI.shared.baseUrl
        self.maskedApiKey = KeychainManager.shared.getMaskedApiKey()
        self.isBiometricsEnabled = BiometricAuthManager.shared.isBiometricsEnabled
        
        let savedFontSize = UserDefaults.standard.double(forKey: consoleFontSizeKey)
        self.consoleFontSize = savedFontSize > 0 ? savedFontSize : 12.0
        
        if UserDefaults.standard.object(forKey: autoScrollKey) != nil {
            self.autoScrollDefault = UserDefaults.standard.bool(forKey: autoScrollKey)
        } else {
            self.autoScrollDefault = true
        }
    }
    
    func savePanelUrl() {
        PterodactylAPI.shared.baseUrl = panelUrl
        statusMessage = "URL actualizada correctamente."
        HapticFeedback.success()
    }
    
    func updateApiKey() {
        let trimmed = newApiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if KeychainManager.shared.saveApiKey(trimmed) {
            maskedApiKey = KeychainManager.shared.getMaskedApiKey()
            newApiKeyInput = ""
            showApiKeyUpdateSheet = false
            statusMessage = "API Key actualizada correctamente."
            HapticFeedback.success()
        }
    }
    
    func toggleBiometrics(_ enabled: Bool) {
        BiometricAuthManager.shared.isBiometricsEnabled = enabled
        self.isBiometricsEnabled = enabled
        HapticFeedback.light()
    }
    
    func updateConsoleFontSize(_ size: Double) {
        self.consoleFontSize = size
        UserDefaults.standard.set(size, forKey: consoleFontSizeKey)
    }
    
    func updateAutoScroll(_ enabled: Bool) {
        self.autoScrollDefault = enabled
        UserDefaults.standard.set(enabled, forKey: autoScrollKey)
    }
}
