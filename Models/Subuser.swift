import Foundation

struct SubusersResponse: Codable {
    let object: String
    let data: [SubuserData]
}

struct SubuserData: Codable, Identifiable {
    var id: String { attributes.uuid }
    let object: String
    let attributes: SubuserAttributes
}

struct SubuserAttributes: Codable {
    let uuid: String
    let username: String
    let email: String
    let image: String?
    let twoFactorEnabled: Bool
    let permissions: [String]
    
    enum CodingKeys: String, CodingKey {
        case uuid, username, email, image, permissions
        case twoFactorEnabled = "2fa_enabled"
    }
    
    var readablePermissions: [String] {
        permissions.map { perm in
            switch perm {
            case "control.console": return "Consola"
            case "control.start": return "Iniciar"
            case "control.stop": return "Detener"
            case "control.restart": return "Reiniciar"
            case "user.create": return "Añadir Usuarios"
            case "user.read": return "Ver Usuarios"
            case "user.update": return "Modificar Permisos"
            case "user.delete": return "Eliminar Usuarios"
            case "file.create": return "Crear Archivos"
            case "file.read": return "Leer Archivos"
            case "file.update": return "Editar Archivos"
            case "file.delete": return "Borrar Archivos"
            case "file.archive": return "Comprimir Archivos"
            case "file.sftp": return "Acceso SFTP"
            case "backup.create": return "Crear Copias"
            case "backup.read": return "Ver Copias"
            case "backup.delete": return "Borrar Copias"
            case "backup.download": return "Descargar Copias"
            case "backup.restore": return "Restaurar Copias"
            case "allocation.read": return "Ver Puertos"
            case "startup.read": return "Ver Inicio"
            case "startup.update": return "Modificar Inicio"
            case "database.create": return "Crear Bases de Datos"
            case "database.read": return "Ver Bases de Datos"
            case "schedule.create": return "Crear Horarios"
            default:
                return perm
                    .replacingOccurrences(of: ".", with: " ")
                    .capitalized
            }
        }
    }
}
