import SwiftUI

/// Set de iconos limpios vectoriales estilo Apple nativo.
/// Prioriza los assets SVG configurados en Assets.xcassets y ofrece dibujo vectorial nativo como respaldo.
struct CustomIcon: View {
    enum IconType {
        case home
        case servers
        case console
        case files
        case settings
        case powerStart
        case powerRestart
        case powerStop
        case powerKill
        case search
        case refresh
        case lock
        case chevronRight
        case folder
        case document
        
        var assetName: String {
            switch self {
            case .home: return "icon_home"
            case .servers: return "icon_servers"
            case .console: return "icon_console"
            case .files: return "icon_files"
            case .settings: return "icon_settings"
            case .powerStart: return "icon_power_start"
            case .powerRestart: return "icon_power_restart"
            case .powerStop: return "icon_power_stop"
            case .powerKill: return "icon_power_kill"
            default: return ""
            }
        }
        
        var systemFallbackName: String {
            switch self {
            case .home: return "house"
            case .servers: return "server.rack"
            case .console: return "terminal"
            case .files: return "folder"
            case .settings: return "gearshape"
            case .powerStart: return "play.fill"
            case .powerRestart: return "arrow.clockwise"
            case .powerStop: return "stop.fill"
            case .powerKill: return "bolt.fill"
            case .search: return "magnifyingglass"
            case .refresh: return "arrow.clockwise"
            case .lock: return "lock.fill"
            case .chevronRight: return "chevron.right"
            case .folder: return "folder.fill"
            case .document: return "doc.text.fill"
            }
        }
    }
    
    let type: IconType
    var size: CGFloat = 20
    var color: Color = .white
    
    var body: some View {
        Group {
            if !type.assetName.isEmpty, UIImage(named: type.assetName) != nil {
                Image(type.assetName)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: type.systemFallbackName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .foregroundColor(color)
        .frame(width: size, height: size)
    }
}
