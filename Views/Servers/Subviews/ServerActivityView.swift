import SwiftUI

/// Vista de Historial de Actividad real del servidor (GET /api/client/servers/{id}/activity)
/// Estética Apple iOS 26 Liquid Glass en Negro, Azul y Blanco
struct ServerActivityView: View {
    let serverId: String
    
    @State private var activities: [ActivityLogData] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                if isLoading && activities.isEmpty {
                    VStack(spacing: 14) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: SmartTheme.blue))
                            .scaleEffect(1.1)
                        Text("Cargando registro de actividad...")
                            .font(.system(size: 13))
                            .foregroundColor(SmartTheme.textSecondary)
                    }
                    .padding(.top, 60)
                } else if let error = errorMessage, activities.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(SmartTheme.statusOffline)
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(SmartTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        Button {
                            Task { await loadActivity() }
                        } label: {
                            Text("Reintentar")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(SmartTheme.blue)
                        }
                    }
                    .padding(.top, 50)
                } else if activities.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 32))
                            .foregroundColor(SmartTheme.blue.opacity(0.4))
                        Text("Sin actividad reciente")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        Text("No se han registrado eventos ni acciones en este servidor todavía.")
                            .font(.system(size: 13))
                            .foregroundColor(SmartTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(activities) { item in
                        activityRow(item.attributes)
                    }
                }
                
                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
        .refreshable {
            await loadActivity()
        }
        .task {
            await loadActivity()
        }
    }
    
    @ViewBuilder
    private func activityRow(_ log: ActivityLogAttributes) -> some View {
        GlassCard(cornerRadius: 16, padding: 14) {
            HStack(alignment: .top, spacing: 14) {
                // Icono del evento
                ZStack {
                    Circle()
                        .fill(SmartTheme.blue.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: log.eventIcon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(SmartTheme.blueBright)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(log.readableEvent)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(log.formattedDate)
                            .font(.system(size: 11))
                            .foregroundColor(SmartTheme.textMuted)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(SmartTheme.textSecondary)
                        
                        Text(log.actorUsername)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(SmartTheme.textSecondary)
                        
                        if let ip = log.ip, !ip.isEmpty {
                            Text("•")
                                .foregroundColor(SmartTheme.textMuted)
                            Text(ip)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(SmartTheme.textMuted)
                        }
                    }
                }
            }
        }
    }
    
    private func loadActivity() async {
        isLoading = true
        errorMessage = nil
        do {
            self.activities = try await PterodactylAPI.shared.getServerActivity(id: serverId)
        } catch {
            self.errorMessage = "No se pudo obtener el historial de actividad."
        }
        isLoading = false
    }
}
