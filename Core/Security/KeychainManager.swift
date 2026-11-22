import Foundation
import Security

/// Gestor seguro de almacenamiento en el Keychain nativo de iOS.
/// Garantiza que la API Key y credenciales nunca se guarden en texto plano ni en UserDefaults.
final class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "es.lynxnodes.app.keychain"
    private let apiKeyAccount = "pterodactyl_client_api_key"
    
    private init() {}
    
    // MARK: - API Key Management
    
    @discardableResult
    func saveApiKey(_ key: String) -> Bool {
        guard let data = key.data(using: .utf8) else { return false }
        
        // Eliminar clave previa si existía
        deleteApiKey()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func getApiKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    @discardableResult
    func deleteApiKey() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// Devuelve la clave enmascarada para mostrarla de forma segura en la interfaz
    func getMaskedApiKey() -> String {
        guard let key = getApiKey(), !key.isEmpty else { return "No configurada" }
        if key.count <= 10 {
            return "••••••••"
        }
        let prefix = key.prefix(6)
        let suffix = key.suffix(4)
        return "\(prefix)••••••••\(suffix)"
    }
}
