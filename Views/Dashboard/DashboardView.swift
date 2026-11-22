import SwiftUI

/// Pestaña Inicio: Resumen general y acceso rápido a servidores
/// 100% Datos Reales, Cabecera con Icono.jpg y píldora ONLINE, Tab Bar inset corregido
struct DashboardView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // Cabecera Principal con Logo Oficial y Píldora ONLINE
                    HStack(alignment: .center, spacing: 12) {
                        // Icono oficial pequeño con esquinas redondeadas
                        Image("AppLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 38, height: 38)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.4), lineWidth: 0.8)
                            )
                            .shadow(color: Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.25), radius: 6)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("LynxNodes")
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.00, green: 0.75, blue: 0.00),
                                                Color(red: 1.00, green: 0.58, blue: 0.00)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                // Píldora discreta • ONLINE cuando la API responde
                                if viewModel.isApiOnline {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(Color(red: 0.13, green: 0.77, blue: 0.37))
                                            .frame(width: 6, height: 6)
                                        Text("ONLINE")
                                            .font(.system(size: 9, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(red: 0.13, green: 0.77, blue: 0.37))
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color(red: 0.13, green: 0.77, blue: 0.37).opacity(0.12))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(red: 0.13, green: 0.77, blue: 0.37).opacity(0.3), lineWidth: 0.5)
                                    )
                                }
                            }
                            
                            Text("https://panel.lynxnodes.es")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Color(white: 0.50))
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
                                .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.0))
                                .rotationEffect(.degrees(viewModel.isRefreshingSilently ? 360 : 0))
                                .animation(viewModel.isRefreshingSilently ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isRefreshingSilently)
                                .padding(10)
                                .liquidGlass(cornerRadius: 12, strokeOpacity: 0.25, fillOpacity: 0.5)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    
                    // Tarjetas de Resumen de Estado Real (En línea, Iniciando, Apagados)
                    HStack(spacing: 12) {
                        statusSummaryCard(
                            title: "En línea",
                            count: viewModel.runningCount,
                            color: Color(red: 0.13, green: 0.77, blue: 0.37),
                            bgColor: Color(red: 0.13, green: 0.77, blue: 0.37).opacity(0.12)
                        )
                        
                        statusSummaryCard(
                            title: "Iniciando",
                            count: viewModel.startingCount,
                            color: Color(red: 1.00, green: 0.72, blue: 0.00),
                            bgColor: Color(red: 1.00, green: 0.72, blue: 0.00).opacity(0.12)
                        )
                        
                        statusSummaryCard(
                            title: "Apagados",
                            count: viewModel.offlineCount,
                            color: Color(red: 0.94, green: 0.27, blue: 0.27),
                            bgColor: Color(red: 0.94, green: 0.27, blue: 0.27).opacity(0.12)
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
                                        .font(.system(size: 13, weight: .bold))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.0))
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
                                            .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.0).opacity(0.4))
                                        
                                        Text("No hay servidores disponibles")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(white: 0.65))
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
                                            .foregroundColor(Color(white: 0.60))
                                        
                                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                                            Text(formattedRam(Int(viewModel.totalLiveUsedMemoryMB)))
                                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                                .foregroundColor(Color(red: 0.13, green: 0.77, blue: 0.37))
                                            
                                            Text("/ \(formattedRam(viewModel.totalAllocatedMemoryMB))")
                                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                                .foregroundColor(Color(white: 0.50))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Almacenamiento Total")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color(white: 0.60))
                                        
                                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                                            Text(formattedDisk(Int(viewModel.totalLiveUsedDiskMB)))
                                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                                .foregroundColor(Color(red: 0.0, green: 0.90, blue: 1.0))
                                            
                                            Text("/ \(formattedDisk(viewModel.totalAllocatedDiskMB))")
                                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                                .foregroundColor(Color(white: 0.50))
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
                                            .fill(Color(red: 0.13, green: 0.77, blue: 0.37))
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
                    .foregroundColor(Color(white: 0.65))
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
