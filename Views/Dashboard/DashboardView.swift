import SwiftUI

/// Pestaña Inicio: Resumen general y acceso rápido a servidores de SmartBot
/// 100% Datos Reales, estética Apple iOS 26 Liquid Glass en Negro, Azul y Blanco
struct DashboardView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // Cabecera Principal con Logo Oficial SmartBot y Píldora ONLINE
                    HStack(alignment: .center, spacing: 12) {
                        Image("AppLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(SmartTheme.blue.opacity(0.4), lineWidth: 0.8)
                            )
                            .shadow(color: SmartTheme.blue.opacity(0.3), radius: 6)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 8) {
                                Text("SmartBot")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                // Píldora discreta • ONLINE cuando la API responde
                                if viewModel.isApiOnline {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(SmartTheme.statusRunning)
                                            .frame(width: 6, height: 6)
                                        Text("ONLINE")
                                            .font(.system(size: 9, weight: .bold, design: .rounded))
                                            .foregroundColor(SmartTheme.statusRunning)
                                    }
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(SmartTheme.statusRunning.opacity(0.12))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(SmartTheme.statusRunning.opacity(0.25), lineWidth: 0.5)
                                    )
                                }
                            }
                            
                            Text("Sistema de Control de Hosting")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(SmartTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Botón de Actualizar Manual
                        Button {
                            Task {
                                await viewModel.refresh(appEnv: appEnv, showLoading: true)
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(SmartTheme.blue)
                                .rotationEffect(.degrees(viewModel.isRefreshingSilently ? 360 : 0))
                                .animation(
                                    viewModel.isRefreshingSilently ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                    value: viewModel.isRefreshingSilently
                                )
                                .padding(10)
                                .background(SmartTheme.bgCard)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    
                    // Tarjetas de Resumen de Estado Real (En línea, Iniciando, Apagados)
                    HStack(spacing: 12) {
                        statusSummaryCard(
                            title: "En línea",
                            count: viewModel.runningCount,
                            color: SmartTheme.statusRunning,
                            bgColor: SmartTheme.statusRunning.opacity(0.12)
                        )
                        
                        statusSummaryCard(
                            title: "Iniciando",
                            count: viewModel.startingCount,
                            color: SmartTheme.statusStarting,
                            bgColor: SmartTheme.statusStarting.opacity(0.12)
                        )
                        
                        statusSummaryCard(
                            title: "Apagados",
                            count: viewModel.offlineCount,
                            color: SmartTheme.statusOffline,
                            bgColor: SmartTheme.statusOffline.opacity(0.12)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Sección: Acceso Rápido a Servidores
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
                                .foregroundColor(SmartTheme.blue)
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
                                            .foregroundColor(SmartTheme.blue.opacity(0.5))
                                        
                                        Text("No hay servidores disponibles")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(SmartTheme.textSecondary)
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
                    
                    // Métricas globales de uso real y asignación
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recursos de la Infraestructura")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        GlassCard(cornerRadius: 20, padding: 18) {
                            VStack(spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Memoria RAM en Uso Real")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(SmartTheme.textSecondary)
                                        
                                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                                            Text(formattedRam(Int(viewModel.totalLiveUsedMemoryMB)))
                                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                                .foregroundColor(SmartTheme.statusRunning)
                                            
                                            Text("/ \(formattedRam(viewModel.totalAllocatedMemoryMB))")
                                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                                .foregroundColor(SmartTheme.textMuted)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Almacenamiento Total")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(SmartTheme.textSecondary)
                                        
                                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                                            Text(formattedDisk(Int(viewModel.totalLiveUsedDiskMB)))
                                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                                .foregroundColor(SmartTheme.blue)
                                            
                                            Text("/ \(formattedDisk(viewModel.totalAllocatedDiskMB))")
                                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                                .foregroundColor(SmartTheme.textMuted)
                                        }
                                    }
                                }
                                
                                // Barra visual de memoria global
                                GeometryReader { geo in
                                    let maxMem = max(Double(viewModel.totalAllocatedMemoryMB), 1.0)
                                    let ratio = min(max(viewModel.totalLiveUsedMemoryMB / maxMem, 0.0), 1.0)
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white.opacity(0.08))
                                            .frame(height: 5)
                                        Capsule()
                                            .fill(SmartTheme.statusRunning)
                                            .frame(width: max(0, min(geo.size.width * CGFloat(ratio), geo.size.width)), height: 5)
                                    }
                                }
                                .frame(height: 5)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // ESPACIO INFERIOR AMPLIADO: Garantiza que el contenido nunca quede tapado por el Tab Bar
                    Spacer().frame(height: 120)
                }
            }
            .liquidDarkBackground()
            .task {
                await viewModel.refresh(appEnv: appEnv)
                viewModel.startAutoRefresh(appEnv: appEnv)
            }
            .onDisappear {
                viewModel.stopAutoRefresh()
            }
            .refreshable {
                await viewModel.refresh(appEnv: appEnv, showLoading: true)
            }
        }
    }
    
    // MARK: - Tarjeta de Estado
    
    private func statusSummaryCard(title: String, count: Int, color: Color, bgColor: Color) -> some View {
        GlassCard(cornerRadius: 18, padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                        .shadow(color: color.opacity(0.7), radius: 4)
                    Spacer()
                }
                
                Text("\(count)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(SmartTheme.textSecondary)
            }
        }
    }
    
    private func favoriteOrFirstServers() -> [Server] {
        let favs = viewModel.servers.filter { appEnv.isFavorite(serverId: $0.id) }
        if !favs.isEmpty { return favs }
        return Array(viewModel.servers.prefix(3))
    }
    
    private func formattedRam(_ mb: Int) -> String {
        if mb <= 0 { return "0 MB" }
        if mb >= 1024 {
            let gb = Double(mb) / 1024.0
            return String(format: "%.1f GB", gb)
        }
        return "\(mb) MB"
    }
    
    private func formattedDisk(_ mb: Int) -> String {
        if mb <= 0 { return "0 MB" }
        if mb >= 1024 {
            let gb = Double(mb) / 1024.0
            return String(format: "%.1f GB", gb)
        }
        return "\(mb) MB"
    }
}
