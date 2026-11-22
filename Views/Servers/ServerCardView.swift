import SwiftUI

/// Tarjeta de servidor individual con estética SmartBot Liquid Glass y Métricas Reales
struct ServerCardView: View {
    let server: Server
    
    var body: some View {
        GlassCard(cornerRadius: 18, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                // Fila Superior: Nombre, Nodo y Estado Real
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(server.name)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Text(server.node)
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(SmartTheme.blue)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(SmartTheme.blue.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            
                            Text("ID: \(server.id)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(SmartTheme.textMuted)
                        }
                    }
                    
                    Spacer()
                    
                    StatusBadge(state: server.currentState)
                }
                
                Divider()
                    .background(Color.white.opacity(0.08))
                
                // Fila Inferior: Uso Real de Recursos vs Límites
                HStack(spacing: 14) {
                    // CPU Real
                    resourceMetricPill(
                        icon: "cpu",
                        title: "CPU",
                        value: cpuText(),
                        ratio: cpuProgress(),
                        accent: server.currentState == .running ? SmartTheme.blue : Color(white: 0.45)
                    )
                    
                    // RAM Real vs Límite
                    resourceMetricPill(
                        icon: "memorychip",
                        title: "RAM",
                        value: memoryText(),
                        ratio: memoryProgress(),
                        accent: server.currentState == .running ? SmartTheme.statusRunning : Color(white: 0.45)
                    )
                    
                    // Disco Real vs Límite
                    resourceMetricPill(
                        icon: "internaldrive",
                        title: "DISCO",
                        value: diskText(),
                        ratio: diskProgress(),
                        accent: server.currentState == .running ? SmartTheme.blueBright : Color(white: 0.45)
                    )
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(SmartTheme.textMuted)
                }
            }
        }
    }
    
    // MARK: - Cálculos de Métricas Reales
    
    private func cpuText() -> String {
        guard server.currentState == .running, let res = server.currentResources else {
            return "0.0%"
        }
        return res.formattedCpu
    }
    
    private func cpuProgress() -> Double {
        guard server.currentState == .running, let res = server.currentResources else {
            return 0.0
        }
        return res.cpuRatio(limitCpu: server.limits.cpu)
    }
    
    private func memoryText() -> String {
        guard let res = server.currentResources, server.currentState == .running else {
            let limitStr = server.limits.formattedMemory
            return "0 MB / \(limitStr)"
        }
        return res.formattedMemoryWithLimit(limitMB: server.limits.memory)
    }
    
    private func memoryProgress() -> Double {
        guard let res = server.currentResources, server.currentState == .running else {
            return 0.0
        }
        return res.memoryRatio(limitMB: server.limits.memory)
    }
    
    private func diskText() -> String {
        guard let res = server.currentResources else {
            let limitStr = server.limits.formattedDisk
            return "-- / \(limitStr)"
        }
        return res.formattedDiskWithLimit(limitDiskMB: server.limits.disk)
    }
    
    private func diskProgress() -> Double {
        guard let res = server.currentResources else {
            return 0.0
        }
        return res.diskRatio(limitDiskMB: server.limits.disk)
    }
    
    private func resourceMetricPill(
        icon: String,
        title: String,
        value: String,
        ratio: Double,
        accent: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 9))
                    .foregroundColor(SmartTheme.textSecondary)
                Text(title)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundColor(SmartTheme.textSecondary)
            }
            
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            
            // Barra de progreso minimalista
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 3)
                
                Capsule()
                    .fill(accent)
                    .frame(width: max(0, min(50 * CGFloat(ratio), 50)), height: 3)
            }
            .frame(width: 50, height: 3)
        }
    }
}
