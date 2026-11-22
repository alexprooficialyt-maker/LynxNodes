import Foundation

/// Errores tipados y descriptivos para la API de Pterodactyl.
enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(statusCode: Int, message: String?)
    case decodingError(String)
    case connectionFailed
    case missingApiKey
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL del panel no es válida. Comprueba el formato en Ajustes."
        case .unauthorized:
            return "API Key no autorizada o expirada (401). Verifica tu clave en Ajustes."
        case .forbidden:
            return "No tienes permisos suficientes para realizar esta acción (403)."
        case .notFound:
            return "El recurso o servidor solicitado no existe (404)."
        case .rateLimited:
            return "Límite de peticiones alcanzado (429). Espera unos segundos e inténtalo de nuevo."
        case .serverError(let code, let msg):
            if let msg = msg, !msg.isEmpty {
                return "Error del panel (\(code)): \(msg)"
            }
            return "El panel de LynxNodes devolvió un error interno del servidor (\(code))."
        case .decodingError(let detail):
            return "Error al interpretar la respuesta del panel: \(detail)"
        case .connectionFailed:
            return "No se pudo conectar con el servidor. Verifica tu conexión a internet o el estado del panel."
        case .missingApiKey:
            return "No se ha configurado ninguna API Key. Configura una clave para continuar."
        case .custom(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .unauthorized:
            return "Genera una nueva Client API Key en https://panel.lynxnodes.es/account/api e ingrésala en la app."
        case .connectionFailed:
            return "Comprueba si puedes abrir https://panel.lynxnodes.es/ en Safari."
        default:
            return nil
        }
    }
}
