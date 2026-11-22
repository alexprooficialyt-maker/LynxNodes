import SwiftUI

/// Modificador de estilo Liquid Glass (iOS 26 Style) con paleta Negro & Amarillo Dorado Lynx
/// Fondo negro profundo con materiales translúcidos, efecto refracción de cristal/agua,
/// bordes especulares finos (0.5-0.8pt) y esquinas redondeadas continuas.
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var strokeOpacity: Double = 0.16
    var fillOpacity: Double = 0.50
    var shadowRadius: CGFloat = 12
    var highlightGold: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Material translúcido ultra-fino de iOS
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Capa de tinte cristal negro profundo
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(LynxTheme.bgElevated.opacity(fillOpacity))
                    
                    // Brillo especular superior simulando refracción de agua/cristal
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    highlightGold ? LynxTheme.gold.opacity(0.12) : Color.white.opacity(0.08),
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
                        highlightGold ? LynxTheme.specularBorderGradient :
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
            highlightGold: highlightGold
        ))
    }
    
    /// Fondo de pantalla completo oscuro profundo con sutil haz ámbar/oro ambiental de LynxNodes
    func liquidDarkBackground() -> some View {
        ZStack {
            // Fondo base negro azabache absoluto
            LynxTheme.bgBlack
                .ignoresSafeArea()
            
            // Halo ámbar/dorado superior ambiental muy suave
            RadialGradient(
                colors: [
                    LynxTheme.gold.opacity(0.12),
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
