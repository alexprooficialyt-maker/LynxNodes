import SwiftUI

/// Pestaña independiente de Archivos con selector rápido de servidor (Tema Negro y Amarillo)
struct DirectFilesTabView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    @State private var selectedServerId: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if appEnv.cachedServers.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "folder")
                            .font(.system(size: 36))
                            .foregroundColor(LynxTheme.gold.opacity(0.4))
                        
                        Text("No hay servidores disponibles")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(LynxTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Selector Horizontal de Servidores
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Servidor Seleccionado")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(LynxTheme.textSecondary)
                            .padding(.horizontal, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(appEnv.cachedServers) { server in
                                    let isSelected = currentSelectedId() == server.id
                                    Button {
                                        HapticFeedback.light()
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedServerId = server.id
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(server.currentState.color)
                                                .frame(width: 6, height: 6)
                                            
                                            Text(server.name)
                                                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                        }
                                        .foregroundColor(isSelected ? LynxTheme.goldBright : LynxTheme.textSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(isSelected ? LynxTheme.goldGlassGradient : LinearGradient(colors: [Color.white.opacity(0.04)], startPoint: .top, endPoint: .bottom))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(isSelected ? LynxTheme.goldBright.opacity(0.6) : Color.white.opacity(0.06), lineWidth: 0.8)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    
                    Divider()
                        .background(Color.white.opacity(0.08))
                    
                    // Explorador de Archivos del Servidor Seleccionado
                    let activeId = currentSelectedId()
                    if !activeId.isEmpty {
                        FilesBrowserView(serverId: activeId)
                            .id(activeId) // Reinicia el explorer al cambiar de servidor
                    }
                }
            }
            .navigationTitle("Archivos")
            .navigationBarTitleDisplayMode(.inline)
            .liquidDarkBackground()
        }
    }
    
    private func currentSelectedId() -> String {
        if !selectedServerId.isEmpty && appEnv.cachedServers.contains(where: { $0.id == selectedServerId }) {
            return selectedServerId
        }
        return appEnv.cachedServers.first?.id ?? ""
    }
}
