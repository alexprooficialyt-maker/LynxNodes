import SwiftUI

/// Sistema de Diseño SmartBot: Negro Puro (#000000 / #0A0B0F), Azul Apple (#0A84FF / #2563EB) y Blanco (#FFFFFF).
/// Estilo Apple iOS 26 Liquid Glass refinado, sobrio y profesional.
enum SmartTheme {
    // MARK: - Fondos Negros y Grafito OLED
    static let bgBlack = Color(red: 0.00, green: 0.00, blue: 0.00)       // #000000
    static let bgElevated = Color(red: 0.039, green: 0.043, blue: 0.059) // #0A0B0F
    static let bgCard = Color(red: 0.071, green: 0.078, blue: 0.110).opacity(0.75) // #12141C
    
    // MARK: - Azul SmartBot / Apple Blue
    static let blue = Color(red: 0.039, green: 0.518, blue: 1.000)       // #0A84FF
    static let blueBright = Color(red: 0.231, green: 0.510, blue: 0.965) // #3B82F6
    static let blueDark = Color(red: 0.145, green: 0.388, blue: 0.922)   // #2563EB
    static let blueGlow = Color(red: 0.039, green: 0.518, blue: 1.000).opacity(0.25)
    
    // Alias para compatibilidad de componentes
    static let gold = blue
    static let goldBright = blueBright
    static let goldDark = blueDark
    static let goldGlow = blueGlow
    
    // MARK: - Textos y Bordes
    static let textPrimary = Color.white                                  // #FFFFFF
    static let textSecondary = Color(red: 0.612, green: 0.639, blue: 0.686) // #9CA3AF
    static let textMuted = Color(white: 0.45)
    
    // MARK: - Estados de Servidor (Apple System Colors)
    static let statusRunning = Color(red: 0.188, green: 0.820, blue: 0.345) // #30D158 (Verde)
    static let statusStarting = Color(red: 1.000, green: 0.839, blue: 0.039) // #FFD60A (Ámbar)
    static let statusStopping = Color(red: 1.000, green: 0.624, blue: 0.039) // #FF9F0A (Naranja)
    static let statusOffline = Color(red: 1.000, green: 0.271, blue: 0.227)  // #FF453A (Rojo)
    
    // MARK: - Degradados Líquidos
    static let blueGradient = LinearGradient(
        colors: [blueBright, blue, blueDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goldGradient = blueGradient
    
    static let blueGlassGradient = LinearGradient(
        colors: [
            blue.opacity(0.30),
            blueDark.opacity(0.12)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goldGlassGradient = blueGlassGradient
    
    static let specularBorderGradient = LinearGradient(
        stops: [
            .init(color: Color.white.opacity(0.35), location: 0.0),
            .init(color: Color.white.opacity(0.08), location: 0.40),
            .init(color: blue.opacity(0.20), location: 0.80),
            .init(color: Color.white.opacity(0.04), location: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

/// Compatibilidad para código existente
typealias LynxTheme = SmartTheme
