import Foundation
import SwiftUI

/// Estado de ejecución del servidor según Pterodactyl Wings
enum ServerState: String, Codable, CaseIterable {
    case running
    case starting
    case stopping
    case offline
    case unknown
    
    var displayName: String {
        switch self {
        case .running: return "En línea"
        case .starting: return "Iniciando"
        case .stopping: return "Deteniendo"
        case .offline: return "Apagado"
        case .unknown: return "Desconocido"
        }
    }
    
    var color: Color {
        switch self {
        case .running: return Color(red: 0.13, green: 0.77, blue: 0.37) // #22C55E
        case .starting: return Color(red: 1.00, green: 0.72, blue: 0.00) // #FFB800
        case .stopping: return Color(red: 1.00, green: 0.58, blue: 0.00) // #FF9500
        case .offline: return Color(red: 0.94, green: 0.27, blue: 0.27) // #EF4444
        case .unknown: return Color(white: 0.45)
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .running: return Color(red: 0.13, green: 0.77, blue: 0.37).opacity(0.14)
        case .starting: return Color(red: 1.00, green: 0.72, blue: 0.00).opacity(0.14)
        case .stopping: return Color(red: 1.00, green: 0.58, blue: 0.00).opacity(0.14)
        case .offline: return Color(red: 0.94, green: 0.27, blue: 0.27).opacity(0.14)
        case .unknown: return Color.white.opacity(0.06)
        }
    }
    
    var borderColor: Color {
        switch self {
        case .running: return Color(red: 0.13, green: 0.77, blue: 0.37).opacity(0.35)
        case .starting: return Color(red: 1.00, green: 0.72, blue: 0.00).opacity(0.35)
        case .stopping: return Color(red: 1.00, green: 0.58, blue: 0.00).opacity(0.35)
        case .offline: return Color(red: 0.94, green: 0.27, blue: 0.27).opacity(0.35)
        case .unknown: return Color.white.opacity(0.12)
        }
    }
}

/// Señales de energía para POST /api/client/servers/{id}/power
enum PowerSignal: String, Codable {
    case start
    case stop
    case restart
    case kill
    
    var actionName: String {
        switch self {
        case .start: return "Iniciar"
        case .stop: return "Apagar"
        case .restart: return "Reiniciar"
        case .kill: return "Forzar Apagado"
        }
    }
}

/// Límites de recursos asignados al servidor
struct ServerLimits: Codable, Hashable {
    let memory: Int // en MB (0 = ilimitado)
    let swap: Int
    let disk: Int   // en MB (0 = ilimitado)
    let io: Int?
    let cpu: Double // en % (100 = 1 core, 0 = ilimitado)
    
    var formattedMemory: String {
        if memory <= 0 { return "Ilimitada" }
        if memory >= 1024 {
            let gb = Double(memory) / 1024.0
            return String(format: "%.1f GB", gb)
        }
        return "\(memory) MB"
    }
    
    var formattedDisk: String {
        if disk <= 0 { return "Ilimitado" }
        if disk >= 1024 {
            let gb = Double(disk) / 1024.0
            return String(format: "%.1f GB", gb)
        }
        return "\(disk) MB"
    }
    
    var formattedCpu: String {
        if cpu <= 0 { return "Ilimitada" }
        return String(format: "%.0f%%", cpu)
    }
}

/// Datos de conexión SFTP
struct SFTPDetails: Codable, Hashable {
    let ip: String?
    let port: Int?
    
    var connectionString: String {
        guard let ip = ip, let port = port else { return "No disponible" }
        return "\(ip):\(port)"
    }
}

/// Recursos consumidos en tiempo real por el servidor (GET /api/client/servers/{id}/resources)
struct ResourceUsage: Codable, Hashable {
    let memoryBytes: Int64
    let cpuAbsolute: Double
    let diskBytes: Int64
    let networkRxBytes: Int64
    let networkTxBytes: Int64
    let uptime: Int64
    
    enum CodingKeys: String, CodingKey {
        case memoryBytes = "memory_bytes"
        case cpuAbsolute = "cpu_absolute"
        case diskBytes = "disk_bytes"
        case networkRxBytes = "network_rx_bytes"
        case networkTxBytes = "network_tx_bytes"
        case uptime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memoryBytes = try container.decodeIfPresent(Int64.self, forKey: .memoryBytes) ?? 0
        cpuAbsolute = try container.decodeIfPresent(Double.self, forKey: .cpuAbsolute) ?? 0.0
        diskBytes = try container.decodeIfPresent(Int64.self, forKey: .diskBytes) ?? 0
        networkRxBytes = try container.decodeIfPresent(Int64.self, forKey: .networkRxBytes) ?? 0
        networkTxBytes = try container.decodeIfPresent(Int64.self, forKey: .networkTxBytes) ?? 0
        uptime = try container.decodeIfPresent(Int64.self, forKey: .uptime) ?? 0
    }
    
    init(
        memoryBytes: Int64 = 0,
        cpuAbsolute: Double = 0.0,
        diskBytes: Int64 = 0,
        networkRxBytes: Int64 = 0,
        networkTxBytes: Int64 = 0,
        uptime: Int64 = 0
    ) {
        self.memoryBytes = memoryBytes
        self.cpuAbsolute = cpuAbsolute
        self.diskBytes = diskBytes
        self.networkRxBytes = networkRxBytes
        self.networkTxBytes = networkTxBytes
        self.uptime = uptime
    }
    
    var formattedMemoryUsed: String {
        let mb = Double(memoryBytes) / (1024 * 1024)
        if mb >= 1024 {
            return String(format: "%.1f GB", mb / 1024.0)
        }
        return "\(Int(mb)) MB"
    }
    
    func formattedMemoryWithLimit(limitMB: Int) -> String {
        let used = formattedMemoryUsed
        if limitMB <= 0 {
            return "\(used) / ∞"
        }
        let limitStr = limitMB >= 1024 ? String(format: "%.1f GB", Double(limitMB) / 1024.0) : "\(limitMB) MB"
        return "\(used) / \(limitStr)"
    }
    
    func memoryRatio(limitMB: Int) -> Double {
        guard limitMB > 0 else { return 0.0 }
        let limitBytes = Double(limitMB) * 1024 * 1024
        return min(max(Double(memoryBytes) / limitBytes, 0.0), 1.0)
    }
    
    var formattedCpu: String {
        return String(format: "%.1f%%", cpuAbsolute)
    }
    
    func formattedCpuWithLimit(limitCpu: Double) -> String {
        let used = formattedCpu
        if limitCpu <= 0 {
            return "\(used) / ∞"
        }
        return "\(used) / \(Int(limitCpu))%"
    }
    
    func cpuRatio(limitCpu: Double) -> Double {
        let maxCpu = limitCpu > 0 ? limitCpu : 100.0
        return min(max(cpuAbsolute / maxCpu, 0.0), 1.0)
    }
    
    var formattedDiskUsed: String {
        let mb = Double(diskBytes) / (1024 * 1024)
        if mb >= 1024 {
            return String(format: "%.1f GB", mb / 1024.0)
        }
        return "\(Int(mb)) MB"
    }
    
    func formattedDiskWithLimit(limitDiskMB: Int) -> String {
        let used = formattedDiskUsed
        if limitDiskMB <= 0 {
            return "\(used) / ∞"
        }
        let limitStr = limitDiskMB >= 1024 ? String(format: "%.1f GB", Double(limitDiskMB) / 1024.0) : "\(limitDiskMB) MB"
        return "\(used) / \(limitStr)"
    }
    
    func diskRatio(limitDiskMB: Int) -> Double {
        guard limitDiskMB > 0 else { return 0.0 }
        let limitBytes = Double(limitDiskMB) * 1024 * 1024
        return min(max(Double(diskBytes) / limitBytes, 0.0), 1.0)
    }
    
    var formattedUptime: String {
        guard uptime > 0 else { return "0m" }
        let totalSeconds = uptime / 1000
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
}

/// Servidor de Pterodactyl
struct Server: Identifiable, Codable, Hashable {
    let id: String // Mapea a identifier
    let uuid: String
    let name: String
    let node: String
    let description: String?
    let isOwner: Bool
    let limits: ServerLimits
    let sftpDetails: SFTPDetails?
    let isSuspended: Bool
    let isInstalling: Bool
    var currentState: ServerState = .unknown
    var currentResources: ResourceUsage? = nil
    
    enum CodingKeys: String, CodingKey {
        case id = "identifier"
        case uuid
        case name
        case node
        case description
        case isOwner = "server_owner"
        case limits
        case sftpDetails = "sftp_details"
        case isSuspended = "is_suspended"
        case isInstalling = "is_installing"
    }
}

// MARK: - Decodificación de API Pterodactyl

struct PterodactylServerListResponse: Codable {
    let object: String
    let data: [PterodactylServerData]
}

struct PterodactylServerData: Codable {
    let object: String
    let attributes: Server
}

struct PterodactylServerDetailResponse: Codable {
    let object: String
    let attributes: Server
}

// Decodificación de GET /api/client/servers/{identifier}/resources
struct PterodactylResourcesResponse: Codable {
    let object: String
    let attributes: ServerResourceAttributes
}

struct ServerResourceAttributes: Codable {
    let currentState: String
    let isSuspended: Bool
    let resources: ResourceUsage
    
    enum CodingKeys: String, CodingKey {
        case currentState = "current_state"
        case isSuspended = "is_suspended"
        case resources
    }
}
