import SwiftUI

/// Barra de navegación por rutas (Breadcrumbs) para el explorador de archivos
/// Estética Apple iOS 26 Liquid Glass en Negro, Azul y Blanco
struct BreadcrumbsView: View {
    let currentPath: String
    let onSelectPath: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                // Raíz
                Button {
                    HapticFeedback.light()
                    onSelectPath("/")
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(currentPath == "/" ? SmartTheme.blue : SmartTheme.textSecondary)
                        Text("raíz")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(currentPath == "/" ? SmartTheme.blue.opacity(0.2) : Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(currentPath == "/" ? SmartTheme.blue.opacity(0.5) : Color.clear, lineWidth: 0.8)
                    )
                    .foregroundColor(currentPath == "/" ? .white : SmartTheme.textSecondary)
                }
                
                // Segmentos
                let segments = pathSegments()
                ForEach(segments.indices, id: \.self) { index in
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(SmartTheme.textMuted)
                    
                    let segment = segments[index]
                    let isLast = index == segments.count - 1
                    let targetPath = "/" + segments[0...index].joined(separator: "/")
                    
                    Button {
                        HapticFeedback.light()
                        onSelectPath(targetPath)
                    } label: {
                        Text(segment)
                            .font(.system(size: 12, weight: isLast ? .bold : .medium, design: .monospaced))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(isLast ? SmartTheme.blue.opacity(0.25) : Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(isLast ? SmartTheme.blue.opacity(0.6) : Color.clear, lineWidth: 0.8)
                            )
                            .foregroundColor(isLast ? .white : SmartTheme.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
    
    private func pathSegments() -> [String] {
        return currentPath
            .split(separator: "/")
            .map { String($0) }
            .filter { !$0.isEmpty }
    }
}
