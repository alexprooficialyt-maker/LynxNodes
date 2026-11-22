import Foundation

/// Métricas de uso en tiempo real transmitidas por Wings WebSocket
struct ServerStats: Codable, Hashable {
    let memoryBytes: Int64
    let memoryLimitBytes: Int64
    let cpuAbsolute: Double
    let networkRxBytes: Int64
    let networkTxBytes: Int64
    let diskBytes: Int64
    let uptimeMilliseconds: Int64
    let state: ServerState
    
    enum CodingKeys: String, CodingKey {
        case memoryBytes = "memory_bytes"
        case memoryLimitBytes = "memory_limit_bytes"
        case cpuAbsolute = "cpu_absolute"
        case network
        case diskBytes = "disk_bytes"
        case uptime
        case state
    }
    
    struct NetworkPayload: Codable, Hashable {
        let rxBytes: Int64
        let txBytes: Int64
        
        enum CodingKeys: String, CodingKey {
            case rxBytes = "rx_bytes"
            case txBytes = "tx_bytes"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memoryBytes = try container.decodeIfPresent(Int64.self, forKey: .memoryBytes) ?? 0
        memoryLimitBytes = try container.decodeIfPresent(Int64.self, forKey: .memoryLimitBytes) ?? 0
        cpuAbsolute = try container.decodeIfPresent(Double.self, forKey: .cpuAbsolute) ?? 0.0
        diskBytes = try container.decodeIfPresent(Int64.self, forKey: .diskBytes) ?? 0
        uptimeMilliseconds = try container.decodeIfPresent(Int64.self, forKey: .uptime) ?? 0
        
        let stateString = try container.decodeIfPresent(String.self, forKey: .state) ?? "unknown"
        state = ServerState(rawValue: stateString) ?? .unknown
        
        if let net = try? container.decode(NetworkPayload.self, forKey: .network) {
            networkRxBytes = net.rxBytes
            networkTxBytes = net.txBytes
        } else {
            networkRxBytes = 0
            networkTxBytes = 0
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(memoryBytes, forKey: .memoryBytes)
        try container.encode(memoryLimitBytes, forKey: .memoryLimitBytes)
        try container.encode(cpuAbsolute, forKey: .cpuAbsolute)
        try container.encode(diskBytes, forKey: .diskBytes)
        try container.encode(uptimeMilliseconds, forKey: .uptime)
        try container.encode(state.rawValue, forKey: .state)
        let net = NetworkPayload(rxBytes: networkRxBytes, txBytes: networkTxBytes)
        try container.encode(net, forKey: .network)
    }
    
    init(
        memoryBytes: Int64 = 0,
        memoryLimitBytes: Int64 = 0,
        cpuAbsolute: Double = 0.0,
        networkRxBytes: Int64 = 0,
        networkTxBytes: Int64 = 0,
        diskBytes: Int64 = 0,
        uptimeMilliseconds: Int64 = 0,
        state: ServerState = .unknown
    ) {
        self.memoryBytes = memoryBytes
        self.memoryLimitBytes = memoryLimitBytes
        self.cpuAbsolute = cpuAbsolute
        self.networkRxBytes = networkRxBytes
        self.networkTxBytes = networkTxBytes
        self.diskBytes = diskBytes
        self.uptimeMilliseconds = uptimeMilliseconds
        self.state = state
    }
    
    // MARK: - Propiedades formateadas para la UI
    
    var formattedCpu: String {
        return String(format: "%.1f%%", cpuAbsolute)
    }
    
    var cpuProgress: Double {
        return min(max(cpuAbsolute / 100.0, 0.0), 1.0)
    }
    
    var formattedMemoryUsed: String {
        let mb = Double(memoryBytes) / (1024 * 1024)
        if mb >= 1024 {
            return String(format: "%.2f GB", mb / 1024.0)
        }
        return String(format: "%.0f MB", mb)
    }
    
    var formattedMemoryLimit: String {
        if memoryLimitBytes <= 0 { return "Ilimitada" }
        let mb = Double(memoryLimitBytes) / (1024 * 1024)
        if mb >= 1024 {
            return String(format: "%.2f GB", mb / 1024.0)
        }
        return String(format: "%.0f MB", mb)
    }
    
    var memoryRatio: Double {
        guard memoryLimitBytes > 0 else { return 0.0 }
        return min(max(Double(memoryBytes) / Double(memoryLimitBytes), 0.0), 1.0)
    }
    
    var formattedDisk: String {
        let mb = Double(diskBytes) / (1024 * 1024)
        if mb >= 1024 {
            return String(format: "%.2f GB", mb / 1024.0)
        }
        return String(format: "%.0f MB", mb)
    }
    
    var formattedNetworkRx: String {
        return Self.formatBytes(networkRxBytes)
    }
    
    var formattedNetworkTx: String {
        return Self.formatBytes(networkTxBytes)
    }
    
    var formattedUptime: String {
        guard uptimeMilliseconds > 0 else { return "0m" }
        let totalSeconds = uptimeMilliseconds / 1000
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private static func formatBytes(_ bytes: Int64) -> String {
        let b = Double(bytes)
        if b >= 1024 * 1024 * 1024 {
            return String(format: "%.1f GB", b / (1024 * 1024 * 1024))
        } else if b >= 1024 * 1024 {
            return String(format: "%.1f MB", b / (1024 * 1024))
        } else if b >= 1024 {
            return String(format: "%.1f KB", b / 1024)
        }
        return "\(bytes) B"
    }
}
