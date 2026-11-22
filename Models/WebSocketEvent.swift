import Foundation

/// Mensajes de protocolo de Wings WebSocket
struct WebSocketMessage: Codable {
    let event: String
    let args: [String]?
    
    init(event: String, args: [String]? = nil) {
        self.event = event
        self.args = args
    }
}

/// Respuesta de token WebSocket de la API REST
struct WebSocketTokenData: Codable {
    let token: String
    let socket: String
}

struct WebSocketTokenResponse: Codable {
    let data: WebSocketTokenData
}
