import SwiftUI

/// Sistema de Diseño LynxNodes: Negro Profundo (OLED Obsidian) y Amarillo Oro (Lynx Amber Gold)
/// Estilo Apple Liquid Glass refinado, sin saturaciones estridentes y con acabado de alta fidelidad.
enum LynxTheme {
    // MARK: - Fondos Negros OLED
    static let bgBlack = Color(red: 0.03, green: 0.03, blue: 0.04)
    static let bgElevated = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let bgCard = Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.65)
    
    // MARK: - Amarillo / Dorado Lynx (Lynx Gold & Amber)
    static let gold = Color(red: 0.96, green: 0.72, blue: 0.00)       // #F5B700 - Dorado principal
    static let goldBright = Color(red: 1.00, green: 0.82, blue: 0.20) // #FFD133 - Brillo luminoso
    static let goldDark = Color(red: 0.82, green: 0.58, blue: 0.00)   // #D19400 - Ámbar profundo
    static let goldGlow = Color(red: 0.96, green: 0.72, blue: 0.00).opacity(0.25)
    
    // MARK: - Textos
    static let textPrimary = Color(red: 0.98, green: 0.98, blue: 0.99)
    static let textSecondary = Color(white: 0.65)
    static let textMuted = Color(white: 0.40)
    
    // MARK: - Estados de Servidor
    static let statusRunning = Color(red: 0.25, green: 0.85, blue: 0.45)
    static let statusStarting = Color(red: 0.96, green: 0.72, blue: 0.00) // Amarillo Lynx
    static let statusStopping = Color(red: 0.95, green: 0.55, blue: 0.15)
    static let statusOffline = Color(red: 0.92, green: 0.30, blue: 0.30)
    
    // MARK: - Degradados
    static let goldGradient = LinearGradient(
        colors: [goldBright, gold, goldDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goldGlassGradient = LinearGradient(
        colors: [
            gold.opacity(0.28),
            goldDark.opacity(0.16)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let specularBorderGradient = LinearGradient(
        stops: [
            .init(color: goldBright.opacity(0.50), location: 0.0),
            .init(color: Color.white.opacity(0.18), location: 0.35),
            .init(color: gold.opacity(0.15), location: 0.75),
            .init(color: Color.white.opacity(0.04), location: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
