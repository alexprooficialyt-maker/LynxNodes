import SwiftUI

/// Pestaña Inicio: Resumen general y acceso rápido a servidores (Tema Negro y Amarillo)
struct DashboardView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Cabecera Principal con Identidad Lynx
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 5) {
                                Text("LYNX")
                                    .font(.system(size: 26, weight: .black, design: .rounded))
                                    .foregroundColor(LynxTheme.goldBright)
                                Text("NODES")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Panel de Infraestructura")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(LynxTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            Task {
                                await viewModel.refresh(appEnv: appEnv)
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(LynxTheme.goldBright)
                                .padding(10)
                                .liquidGlass(cornerRadius: 14, strokeOpacity: 0.25, fillOpacity: 0.5)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Tarjetas de Resumen de Estado (Encendidos, Iniciando, Apagados)
                    HStack(spacing: 12) {
                        statusSummaryCard(
                            title: "En línea",
                            count: viewModel.runningCount,
                            color: LynxTheme.statusRunning
                        )
                        
                        statusSummaryCard(
                            title: "Iniciando",
                            count: viewModel.startingCount,
                            color: LynxTheme.goldBright
                        )
                        
                        statusSummaryCard(
                            title: "Apagados",
                            count: viewModel.offlineCount,
                            color: LynxTheme.statusOffline
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Sección: Servidores Favoritos / Acceso Rápido
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Acceso Rápido")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button {
                                appEnv.selectedTab = .servers
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Ver todos")
                                        .font(.system(size: 13, weight: .semibold))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundColor(LynxTheme.goldBright)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        let quickServers = favoriteOrFirstServers()
                        if quickServers.isEmpty {
                            if viewModel.isLoading {
                                SkeletonLoader()
                            } else {
                                GlassCard(cornerRadius: 18, padding: 22) {
                                    VStack(spacing: 10) {
                                        Image(systemName: "server.rack")
                                            .font(.system(size: 30))
                                            .foregroundColor(LynxTheme.gold.opacity(0.4))
                                        
                                        Text("No hay servidores disponibles")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(LynxTheme.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 20)
                            }
                        } else {
                            VStack(spacing: 12) {
                                ForEach(quickServers) { server in
                                    NavigationLink {
                                        ServerDetailView(server: server)
                                    } label: {
                                        ServerCardView(server: server)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Métricas globales de asignación
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recursos Asignados")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        GlassCard(cornerRadius: 20, padding: 18) {
                            VStack(spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Memoria RAM Asignada")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(LynxTheme.textSecondary)
                                        
                                        Text(formattedRam(viewModel.totalAllocatedMemoryMB))
                                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                                            .foregroundColor(LynxTheme.goldBright)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Almacenamiento Total")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(LynxTheme.textSecondary)
                                        
                                        Text(formattedDisk(viewModel.totalAllocatedDiskMB))
                                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer().frame(height: 100) // Espacio para el Tab Bar flotante
                }
            }
            .liquidDarkBackground()
            .task {
                await viewModel.refresh(appEnv: appEnv)
            }
            .refreshable {
                await viewModel.refresh(appEnv: appEnv)
            }
        }
    }
    
    // MARK: - Tarjeta de Estado
    
    private func statusSummaryCard(title: String, count: Int, color: Color) -> some View {
        GlassCard(cornerRadius: 18, padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                        .shadow(color: color.opacity(0.6), radius: 3)
                    Spacer()
                }
                
                Text("\(count)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(LynxTheme.textSecondary)
            }
        }
    }
    
    private func favoriteOrFirstServers() -> [Server] {
        let favs = viewModel.servers.filter { appEnv.isFavorite(serverId: $0.id) }
        if !favs.isEmpty { return favs }
        return Array(viewModel.servers.prefix(3))
    }
    
    private func formattedRam(_ mb: Int) -> String {
        if mb >= 1024 {
            let gb = Double(mb) / 1024.0
            return String(format: "%.1f GB", gb)
        }
        return "\(mb) MB"
    }
    
    private func formattedDisk(_ mb: Int) -> String {
        if mb >= 1024 {
            let gb = Double(mb) / 1024.0
            return String(format: "%.1f GB", gb)
        }
        return "\(mb) MB"
    }
}
