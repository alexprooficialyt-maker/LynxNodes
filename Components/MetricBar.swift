import SwiftUI

/// Barra minimalista de métricas (CPU, RAM, Disco)
/// Estética Apple iOS 26 Liquid Glass en Negro, Azul y Blanco
struct MetricBar: View {
    let title: String
    let valueText: String
    let progress: Double // 0.0 a 1.0
    var tintColor: Color = SmartTheme.blue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(SmartTheme.textSecondary)
                
                Spacer()
                
                Text(valueText)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            // Barra de progreso
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Fondo de pista
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 5)
                    
                    // Barra activa en Degradado Azul
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    tintColor.opacity(0.85),
                                    SmartTheme.blueBright
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(geo.size.width * CGFloat(progress), geo.size.width)), height: 5)
                        .animation(.easeInOut(duration: 0.35), value: progress)
                }
            }
            .frame(height: 5)
        }
    }
}
