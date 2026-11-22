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
        case .running: return Color(red: 0.22, green: 0.85, blue: 0.45)
        case .starting: return Color(red: 1.0, green: 0.82, blue: 0.25)
        case .stopping: return Color(red: 1.0, green: 0.55, blue: 0.20)
        case .offline: return Color(red: 0.95, green: 0.32, blue: 0.32)
        case .unknown: return Color.gray
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

// MARK: - Decodificación de API Pterodactyl (/api/client)

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
