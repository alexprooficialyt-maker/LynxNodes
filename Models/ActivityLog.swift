import Foundation

struct ActivityLogResponse: Codable {
    let object: String
    let data: [ActivityLogData]
}

struct ActivityLogData: Codable, Identifiable {
    var id: String {
        attributes.timestamp + attributes.event + (attributes.ip ?? "") + UUID().uuidString
    }
    let object: String
    let attributes: ActivityLogAttributes
}

struct ActivityLogAttributes: Codable {
    let event: String
    let ip: String?
    let isApi: Bool?
    let description: String?
    let timestamp: String
    let relationships: ActivityLogRelationships?
    
    enum CodingKeys: String, CodingKey {
        case event, ip, description, timestamp, relationships
        case isApi = "is_api"
    }
    
    var actorUsername: String {
        relationships?.actor?.attributes.username ?? "Sistema"
    }
    
    var actorEmail: String? {
        relationships?.actor?.attributes.email
    }
    
    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = isoFormatter.date(from: timestamp)
        if date == nil {
            isoFormatter.formatOptions = [.withInternetDateTime]
            date = isoFormatter.date(from: timestamp)
        }
        guard let d = date else { return timestamp }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.localizedString(for: d, relativeTo: Date())
    }
    
    var readableEvent: String {
        switch event {
        case "server:power.start": return "Iniciar Servidor"
        case "server:power.stop": return "Detener Servidor"
        case "server:power.restart": return "Reiniciar Servidor"
        case "server:power.kill": return "Forzar Apagado"
        case "server:console.command": return "Comando de Consola"
        case "server:file.write": return "Modificar Archivo"
        case "server:file.create-folder": return "Crear Carpeta"
        case "server:file.delete": return "Eliminar Archivo"
        case "server:file.rename": return "Renombrar Archivo"
        case "server:file.upload": return "Subir Archivo"
        case "server:backup.create": return "Crear Copia de Seguridad"
        case "server:backup.restore": return "Restaurar Copia"
        case "server:backup.delete": return "Eliminar Copia"
        case "server:subuser.create": return "Añadir Usuario"
        case "server:subuser.update": return "Modificar Permisos"
        case "server:subuser.delete": return "Eliminar Usuario"
        case "server:schedule.create": return "Crear Tarea Programada"
        case "server:startup.variable": return "Cambiar Parámetro de Inicio"
        default:
            return event
                .replacingOccurrences(of: "server:", with: "")
                .replacingOccurrences(of: ".", with: " ")
                .capitalized
        }
    }
    
    var eventIcon: String {
        if event.contains("power.start") { return "play.fill" }
        if event.contains("power.stop") { return "stop.fill" }
        if event.contains("power.restart") { return "arrow.clockwise" }
        if event.contains("power.kill") { return "bolt.fill" }
        if event.contains("console") { return "terminal.fill" }
        if event.contains("file") { return "doc.text.fill" }
        if event.contains("backup") { return "archivebox.fill" }
        if event.contains("subuser") { return "person.2.fill" }
        return "clock.arrow.circlepath"
    }
}

struct ActivityLogRelationships: Codable {
    let actor: ActivityLogActor?
}

struct ActivityLogActor: Codable {
    let object: String
    let attributes: ActivityLogActorAttributes
}

struct ActivityLogActorAttributes: Codable {
    let uuid: String?
    let username: String
    let email: String?
}
