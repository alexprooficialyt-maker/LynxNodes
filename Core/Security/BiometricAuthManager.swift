import Foundation
import LocalAuthentication

/// Gestor de autenticación biométrica (Face ID / Touch ID) para proteger el acceso a la app.
final class BiometricAuthManager {
    static let shared = BiometricAuthManager()
    
    private let biometricsEnabledKey = "lynxnodes_biometrics_enabled"
    
    private init() {}
    
    var isBiometricsEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: biometricsEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: biometricsEnabledKey)
        }
    }
    
    enum BiometryType {
        case faceID
        case touchID
        case opticID
        case none
    }
    
    var biometryType: BiometryType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .opticID
        @unknown default:
            return .faceID
        }
    }
    
    var biometryName: String {
        switch biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .none: return "Bloqueo Biométrico"
        }
    }
    
    func authenticate(reason: String = "Desbloquea LynxNodes para acceder a tus servidores") async -> Result<Bool, Error> {
        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Si la biometría no está disponible, intentar con código del dispositivo
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                do {
                    let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
                    return .success(success)
                } catch {
                    return .failure(error)
                }
            }
            return .failure(error ?? NSError(domain: "Biometrics", code: -1, userInfo: [NSLocalizedDescriptionKey: "Autenticación no disponible"]))
        }
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return .success(success)
        } catch {
            return .failure(error)
        }
    }
}
