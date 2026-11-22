import SwiftUI

/// Panel de Control del Servidor: Consola en tiempo real + Gestor de Archivos (Tema Negro y Amarillo)
struct ServerDetailView: View {
    let server: Server
    
    @EnvironmentObject private var appEnv: AppEnvironment
    @StateObject private var consoleViewModel: ServerConsoleViewModel
    @State private var selectedSubTab: ServerSubTab = .console
    
    enum ServerSubTab: String, CaseIterable, Identifiable {
        case console = "Consola"
        case files = "Archivos"
        
        var id: String { rawValue }
    }
    
    init(server: Server) {
        self.server = server
        _consoleViewModel = StateObject(wrappedValue: ServerConsoleViewModel(server: server))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Cabecera del Servidor con selector de sub-pestañas
            VStack(spacing: 12) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(server.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Text(server.node)
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(LynxTheme.goldBright)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(LynxTheme.gold.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(LynxTheme.gold.opacity(0.25), lineWidth: 0.5)
                                )
                            
                            Text(server.id)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(LynxTheme.textMuted)
                        }
                    }
                    
                    Spacer()
                    
                    // Botón Favorito
                    Button {
                        appEnv.toggleFavorite(serverId: server.id)
                    } label: {
                        Image(systemName: appEnv.isFavorite(serverId: server.id) ? "star.fill" : "star")
                            .font(.system(size: 16))
                            .foregroundColor(appEnv.isFavorite(serverId: server.id) ? LynxTheme.goldBright : Color(white: 0.45))
                            .padding(8)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                    }
                    
                    StatusBadge(state: consoleViewModel.serverState)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Selector de Sub-pestañas (Consola / Archivos)
                HStack(spacing: 6) {
                    ForEach(ServerSubTab.allCases) { tab in
                        let isSelected = selectedSubTab == tab
                        Button {
                            HapticFeedback.light()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                selectedSubTab = tab
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: tab == .console ? "terminal" : "folder")
                                    .font(.system(size: 12, weight: .semibold))
                                
                                Text(tab.rawValue)
                                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                            }
                            .foregroundColor(isSelected ? LynxTheme.goldBright : LynxTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(isSelected ? LynxTheme.goldGlassGradient : LinearGradient(colors: [Color.white.opacity(0.04)], startPoint: .top, endPoint: .bottom))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(isSelected ? LynxTheme.goldBright.opacity(0.5) : Color.white.opacity(0.06), lineWidth: 0.8)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
            .background(LynxTheme.bgElevated.opacity(0.90))
            
            Divider()
                .background(Color.white.opacity(0.08))
            
            // Contenido según sub-pestaña
            Group {
                switch selectedSubTab {
                case .console:
                    ConsoleView(viewModel: consoleViewModel)
                case .files:
                    FilesBrowserView(serverId: server.id)
                }
            }
        }
        .liquidDarkBackground()
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await consoleViewModel.connect()
        }
        .onDisappear {
            consoleViewModel.disconnect()
        }
    }
}
