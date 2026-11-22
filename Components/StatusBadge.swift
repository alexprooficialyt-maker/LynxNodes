import SwiftUI

/// Indicador visual del estado del servidor (punto LED + texto con colores reales de LynxNodes)
struct StatusBadge: View {
    let state: ServerState
    var showText: Bool = true
    
    @State private var isPulsing = false
    
    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                // Brillo difuso / halo
                Circle()
                    .fill(state.color.opacity(0.35))
                    .frame(width: 14, height: 14)
                    .scaleEffect(isPulsing && (state == .starting || state == .running) ? 1.3 : 1.0)
                    .opacity(isPulsing && state == .starting ? 0.3 : 0.6)
                
                // Punto LED central
                Circle()
                    .fill(state.color)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                    )
            }
            
            if showText {
                Text(state.displayName)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(state.color)
            }
        }
        .padding(.horizontal, showText ? 9 : 5)
        .padding(.vertical, 5)
        .background(state.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(state.borderColor, lineWidth: 0.8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onAppear {
            if state == .starting || state == .stopping {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
        }
    }
}
