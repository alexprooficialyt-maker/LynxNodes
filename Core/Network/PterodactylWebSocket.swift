import Foundation

/// Delegate / Callbacks para eventos del WebSocket de Wings
protocol PterodactylWebSocketDelegate: AnyObject {
    func webSocketDidConnect()
    func webSocketDidDisconnect(error: Error?)
    func webSocketDidReceiveLog(_ log: String)
    func webSocketDidChangeStatus(_ status: ServerState)
    func webSocketDidUpdateStats(_ stats: ServerStats)
    func webSocketTokenNeedsRefresh()
}

/// Cliente WebSocket nativo para la consola y métricas en tiempo real de Wings (Pterodactyl)
final class PterodactylWebSocket {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    
    private var currentToken: String
    private let socketUrl: URL
    private var isConnected = false
    private var isIntentionallyClosed = false
    
    weak var delegate: PterodactylWebSocketDelegate?
    
    init(socketUrl: URL, token: String) {
        self.socketUrl = socketUrl
        self.currentToken = token
    }
    
    // MARK: - Ciclo de Conexión
    
    func connect() {
        isIntentionallyClosed = false
        
        let config = URLSessionConfiguration.default
        urlSession = URLSession(configuration: config)
        
        var request = URLRequest(url: socketUrl)
        request.setValue("https://panel.lynxnodes.es", forHTTPHeaderField: "Origin")
        
        webSocketTask = urlSession?.webSocketTask(with: request)
        webSocketTask?.resume()
        
        // Autenticación inicial inmediata
        sendAuthToken(currentToken)
        listenForMessages()
    }
    
    func disconnect() {
        isIntentionallyClosed = true
        isConnected = false
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
    }
    
    func updateTokenAndReauth(_ newToken: String) {
        self.currentToken = newToken
        sendAuthToken(newToken)
    }
    
    // MARK: - Envío de Comandos y Eventos
    
    private func sendAuthToken(_ token: String) {
        let authMessage = WebSocketMessage(event: "auth", args: [token])
        send(message: authMessage)
    }
    
    func sendCommand(_ command: String) {
        guard !command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let message = WebSocketMessage(event: "send command", args: [command])
        send(message: message)
    }
    
    func requestLogs() {
        let message = WebSocketMessage(event: "send logs", args: ["0"])
        send(message: message)
    }
    
    func setPowerState(_ signal: PowerSignal) {
        let message = WebSocketMessage(event: "set state", args: [signal.rawValue])
        send(message: message)
    }
    
    private func send(message: WebSocketMessage) {
        guard let data = try? JSONEncoder().encode(message),
              let string = String(data: data, encoding: .utf8) else {
            return
        }
        
        let wsMessage = URLSessionWebSocketTask.Message.string(string)
        webSocketTask?.send(wsMessage) { error in
            if let error = error {
                print("[WebSocket] Error al enviar mensaje: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Recepción y Procesamiento de Mensajes
    
    private func listenForMessages() {
        guard let task = webSocketTask else { return }
        
        task.receive { [weak self] result in
            guard let self = self, !self.isIntentionallyClosed else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleIncomingString(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleIncomingString(text)
                    }
                @unknown default:
                    break
                }
                // Continuar escuchando el siguiente mensaje
                self.listenForMessages()
                
            case .failure(let error):
                if !self.isIntentionallyClosed {
                    self.isConnected = false
                    DispatchQueue.main.async {
                        self.delegate?.webSocketDidDisconnect(error: error)
                    }
                }
            }
        }
    }
    
    private func handleIncomingString(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            let message = try JSONDecoder().decode(WebSocketMessage.self, from: data)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch message.event {
                case "auth success":
                    self.isConnected = true
                    self.requestLogs()
                    self.delegate?.webSocketDidConnect()
                    
                case "token expiring", "token expired":
                    self.delegate?.webSocketTokenNeedsRefresh()
                    
                case "status":
                    if let rawStatus = message.args?.first {
                        let state = ServerState(rawValue: rawStatus) ?? .unknown
                        self.delegate?.webSocketDidChangeStatus(state)
                    }
                    
                case "console output":
                    if let logChunk = message.args?.first {
                        self.delegate?.webSocketDidReceiveLog(logChunk)
                    }
                    
                case "stats":
                    if let statsJsonString = message.args?.first,
                       let statsData = statsJsonString.data(using: .utf8) {
                        if let stats = try? JSONDecoder().decode(ServerStats.self, from: statsData) {
                            self.delegate?.webSocketDidUpdateStats(stats)
                        }
                    }
                    
                default:
                    break
                }
            }
        } catch {
            // Mensaje no estructurado o ping/pong
        }
    }
}
