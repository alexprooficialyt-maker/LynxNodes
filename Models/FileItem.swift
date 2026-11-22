import Foundation
import SwiftUI

/// Representa un archivo o directorio dentro del servidor
struct FileItem: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let mode: String
    let modeBits: String
    let size: Int64
    let isFile: Bool
    let isSymlink: Bool
    let mimetype: String?
    let createdAt: String?
    let modifiedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case mode
        case modeBits = "mode_bits"
        case size
        case isFile = "is_file"
        case isSymlink = "is_symlink"
        case mimetype
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
    }
    
    var isDirectory: Bool {
        return !isFile
    }
    
    var formattedSize: String {
        if isDirectory { return "--" }
        let bytes = Double(size)
        if bytes >= 1024 * 1024 * 1024 {
            return String(format: "%.1f GB", bytes / (1024 * 1024 * 1024))
        } else if bytes >= 1024 * 1024 {
            return String(format: "%.1f MB", bytes / (1024 * 1024))
        } else if bytes >= 1024 {
            return String(format: "%.1f KB", bytes / 1024)
        }
        return "\(size) B"
    }
    
    var fileExtension: String {
        (name as NSString).pathExtension.lowercased()
    }
    
    var isEditableText: Bool {
        if isDirectory { return false }
        let textExtensions: Set<String> = [
            "txt", "json", "yml", "yaml", "env", "properties", "cfg", "conf",
            "ini", "log", "md", "js", "ts", "py", "sh", "lua", "xml", "toml", "html", "css"
        ]
        if textExtensions.contains(fileExtension) { return true }
        if let mime = mimetype, mime.hasPrefix("text/") || mime.contains("json") || mime.contains("javascript") {
            return true
        }
        return false
    }
    
    var iconName: String {
        if isDirectory { return "folder.fill" }
        switch fileExtension {
        case "json", "yml", "yaml", "env", "properties", "toml", "conf", "ini":
            return "gearshape.fill"
        case "js", "ts", "py", "sh", "lua", "html", "css":
            return "chevron.left.forwardslash.chevron.right"
        case "zip", "tar", "gz", "rar", "7z":
            return "doc.zipper"
        case "png", "jpg", "jpeg", "gif", "webp", "svg":
            return "photo.fill"
        case "log", "txt", "md":
            return "doc.text.fill"
        case "jar":
            return "cube.fill"
        default:
            return "doc.fill"
        }
    }
}

// MARK: - Decodificación de API Pterodactyl (/api/client/servers/{id}/files/list)

struct PterodactylFileListResponse: Codable {
    let object: String
    let data: [PterodactylFileData]
}

struct PterodactylFileData: Codable {
    let object: String
    let attributes: FileItem
}
