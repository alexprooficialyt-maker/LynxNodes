import SwiftUI

/// Indicador visual del estado del servidor (punto LED + texto opcional)
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
                    .scaleEffect(isPulsing && state == .starting ? 1.4 : 1.0)
                    .opacity(isPulsing && state == .starting ? 0.2 : 0.6)
                
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
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(state.color)
            }
        }
        .padding(.horizontal, showText ? 8 : 4)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(state.color.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(state.color.opacity(0.25), lineWidth: 0.5)
        )
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
