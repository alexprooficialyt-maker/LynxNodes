import SwiftUI

/// Tarjeta de servidor individual con estética Liquid Glass
struct ServerCardView: View {
    let server: Server
    
    var body: some View {
        GlassCard(cornerRadius: 18, padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                // Fila Superior: Nombre, Nodo y Estado
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(server.name)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Text(server.node)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(white: 0.55))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            
                            Text("ID: \(server.id)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Color(white: 0.40))
                        }
                    }
                    
                    Spacer()
                    
                    StatusBadge(state: server.currentState)
                }
                
                Divider()
                    .background(Color.white.opacity(0.08))
                
                // Fila Inferior: Asignación de Recursos
                HStack(spacing: 16) {
                    resourcePill(
                        icon: "cpu",
                        title: "CPU",
                        value: server.limits.formattedCpu
                    )
                    
                    resourcePill(
                        icon: "memorychip",
                        title: "RAM",
                        value: server.limits.formattedMemory
                    )
                    
                    resourcePill(
                        icon: "internaldrive",
                        title: "Disco",
                        value: server.limits.formattedDisk
                    )
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(white: 0.35))
                }
            }
        }
    }
    
    private func resourcePill(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(Color(white: 0.50))
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(Color(white: 0.45))
                Text(value)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(white: 0.85))
            }
        }
    }
}
