import SwiftUI

/// Modificador de estilo Liquid Glass (iOS 26 Style) con paleta Negro, Azul y Blanco
/// Fondo negro profundo con materiales translúcidos, efecto refracción de cristal/agua,
/// bordes especulares finos (0.5-0.8pt) y esquinas redondeadas continuas.
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var strokeOpacity: Double = 0.16
    var fillOpacity: Double = 0.50
    var shadowRadius: CGFloat = 12
    var highlightBlue: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Material translúcido ultra-fino de iOS
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Capa de tinte cristal negro profundo
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(SmartTheme.bgElevated.opacity(fillOpacity))
                    
                    // Brillo especular superior simulando refracción de agua/cristal
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    highlightBlue ? SmartTheme.blue.opacity(0.12) : Color.white.opacity(0.08),
                                    Color.white.opacity(0.02),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                // Borde especular fino de 0.8pt
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        highlightBlue ? SmartTheme.specularBorderGradient :
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(strokeOpacity + 0.14), location: 0.0),
                                    .init(color: Color.white.opacity(strokeOpacity), location: 0.4),
                                    .init(color: Color.white.opacity(strokeOpacity * 0.4), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                        lineWidth: 0.8
                    )
            )
            .shadow(color: Color.black.opacity(0.45), radius: shadowRadius, x: 0, y: 6)
    }
}

extension View {
    func liquidGlass(
        cornerRadius: CGFloat = 20,
        strokeOpacity: Double = 0.16,
        fillOpacity: Double = 0.50,
        shadowRadius: CGFloat = 12,
        highlightGold: Bool = false
    ) -> some View {
        modifier(LiquidGlassModifier(
            cornerRadius: cornerRadius,
            strokeOpacity: strokeOpacity,
            fillOpacity: fillOpacity,
            shadowRadius: shadowRadius,
            highlightBlue: highlightGold
        ))
    }
    
    /// Fondo de pantalla completo oscuro profundo con sutil haz azul ambiental de SmartBot
    func liquidDarkBackground() -> some View {
        ZStack {
            // Fondo base negro azabache absoluto
            SmartTheme.bgBlack
                .ignoresSafeArea()
            
            // Halo azul superior ambiental muy suave
            RadialGradient(
                colors: [
                    SmartTheme.blue.opacity(0.10),
                    Color.clear
                ],
                center: .top,
                startRadius: 10,
                endRadius: 450
            )
            .ignoresSafeArea()
            
            self
        }
    }
}
