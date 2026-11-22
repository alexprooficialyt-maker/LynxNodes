import SwiftUI
import Combine

/// Entrada de log con ID único y segmentos ANSI
struct ConsoleLogEntry: Identifiable {
    let id = UUID()
    let rawText: String
    let segments: [ANSISegment]
    let timestamp = Date()
}

/// ViewModel para la consola interactiva en tiempo real y controles de energía
@MainActor
final class ServerConsoleViewModel: ObservableObject, PterodactylWebSocketDelegate {
    let server: Server
    
    @Published var logs: [ConsoleLogEntry] = []
    @Published var serverState: ServerState = .unknown
    @Published var stats: ServerStats = ServerStats()
    @Published var isConnected: Bool = false
    @Published var isConnecting: Bool = false
    @Published var commandInput: String = ""
    @Published var autoScrollEnabled: Bool = true
    @Published var errorMessage: String?
    
    // Alertas de confirmación de energía
    @Published var showStopConfirmation: Bool = false
    @Published var showKillConfirmation: Bool = false
    @Published var isPerformingPowerAction: Bool = false
    
    private var webSocket: PterodactylWebSocket?
    private let maxLogEntries = 1000
    
    init(server: Server) {
        self.server = server
        self.serverState = server.currentState
    }
    
    // MARK: - Ciclo de Vida del WebSocket
    
    func connect() async {
        guard !isConnecting && !isConnected else { return }
        
        isConnecting = true
        errorMessage = nil
        
        do {
            let wsData = try await PterodactylAPI.shared.getWebSocketToken(id: server.id)
            guard let url = URL(string: wsData.socket) else {
                errorMessage = "URL de WebSocket no válida: \(wsData.socket)"
                isConnecting = false
                return
            }
            
            webSocket = PterodactylWebSocket(socketUrl: url, token: wsData.token)
            webSocket?.delegate = self
            webSocket?.connect()
            
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            self.isConnecting = false
        } catch {
            self.errorMessage = "No se pudo conectar a la consola del servidor."
            self.isConnecting = false
        }
    }
    
    func disconnect() {
        webSocket?.disconnect()
        webSocket = nil
        isConnected = false
        isConnecting = false
    }
    
    // MARK: - Enviar Comandos
    
    func sendCurrentCommand() {
        let trimmed = commandInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        HapticFeedback.light()
        webSocket?.sendCommand(trimmed)
        
        // Registrar localmente el comando enviado
        let echoSegment = ANSISegment(text: "> " + trimmed, color: Color(red: 0.40, green: 0.70, blue: 1.0), isBold: true)
        appendLog(ConsoleLogEntry(rawText: trimmed, segments: [echoSegment]))
        
        commandInput = ""
    }
    
    // MARK: - Acciones de Energía
    
    func performPowerAction(_ signal: PowerSignal) async {
        isPerformingPowerAction = true
        HapticFeedback.medium()
        
        do {
            try await PterodactylAPI.shared.sendPowerAction(id: server.id, signal: signal)
            
            // Actualizar estado esperado temporalmente
            switch signal {
            case .start:
                serverState = .starting
            case .restart:
                serverState = .starting
            case .stop:
                serverState = .stopping
            case .kill:
                serverState = .offline
            }
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            HapticFeedback.error()
        } catch {
            self.errorMessage = "Error al ejecutar orden de energía."
            HapticFeedback.error()
        }
        
        isPerformingPowerAction = false
    }
    
    // MARK: - Copiar Logs
    
    func copyAllLogs() {
        let fullText = logs.map { $0.rawText }.joined(separator: "\n")
        UIPasteboard.general.string = fullText
        HapticFeedback.success()
    }
    
    func clearLogs() {
        logs.removeAll()
        HapticFeedback.light()
    }
    
    // MARK: - Delegado WebSocket (PterodactylWebSocketDelegate)
    
    nonisolated func webSocketDidConnect() {
        Task { @MainActor in
            self.isConnected = true
            self.isConnecting = false
        }
    }
    
    nonisolated func webSocketDidDisconnect(error: Error?) {
        Task { @MainActor in
            self.isConnected = false
            self.isConnecting = false
            if let error = error {
                print("[ConsoleVM] WebSocket desconectado: \(error.localizedDescription)")
            }
        }
    }
    
    nonisolated func webSocketDidReceiveLog(_ log: String) {
        Task { @MainActor in
            let clean = log.trimmingCharacters(in: .newlines)
            let segments = ANSIParser.shared.parse(line: clean)
            self.appendLog(ConsoleLogEntry(rawText: clean, segments: segments))
        }
    }
    
    nonisolated func webSocketDidChangeStatus(_ status: ServerState) {
        Task { @MainActor in
            self.serverState = status
        }
    }
    
    nonisolated func webSocketDidUpdateStats(_ stats: ServerStats) {
        Task { @MainActor in
            self.stats = stats
            if stats.state != .unknown {
                self.serverState = stats.state
            }
        }
    }
    
    nonisolated func webSocketTokenNeedsRefresh() {
        Task { @MainActor in
            do {
                let wsData = try await PterodactylAPI.shared.getWebSocketToken(id: self.server.id)
                self.webSocket?.updateTokenAndReauth(wsData.token)
            } catch {
                print("[ConsoleVM] Error al refrescar token de WebSocket")
            }
        }
    }
    
    private func appendLog(_ entry: ConsoleLogEntry) {
        logs.append(entry)
        if logs.count > maxLogEntries {
            logs.removeFirst(logs.count - maxLogEntries)
        }
    }
}
