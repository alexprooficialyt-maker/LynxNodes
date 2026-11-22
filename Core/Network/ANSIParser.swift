import SwiftUI

/// Parser para secuencias de escape ANSI habituales en consolas de servidores (Minecraft, Linux, Node, etc.).
struct ANSISegment: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let color: Color
    let isBold: Bool
}

final class ANSIParser {
    static let shared = ANSIParser()
    
    // Colores base de terminal estilo Dark Slate
    private static let defaultTextColor = Color(red: 0.90, green: 0.92, blue: 0.95)
    private static let blackColor = Color(red: 0.25, green: 0.28, blue: 0.32)
    private static let redColor = Color(red: 1.0, green: 0.38, blue: 0.38)
    private static let greenColor = Color(red: 0.30, green: 0.85, blue: 0.45)
    private static let yellowColor = Color(red: 1.0, green: 0.80, blue: 0.30)
    private static let blueColor = Color(red: 0.40, green: 0.65, blue: 1.0)
    private static let magentaColor = Color(red: 0.85, green: 0.45, blue: 0.95)
    private static let cyanColor = Color(red: 0.35, green: 0.85, blue: 0.95)
    private static let whiteColor = Color(red: 0.98, green: 0.98, blue: 0.98)
    
    /// Convierte una línea de texto con códigos ANSI en una lista de segmentos con color y estilo.
    func parse(line: String) -> [ANSISegment] {
        guard line.contains("\u{1b}[") else {
            return [ANSISegment(text: line, color: Self.defaultTextColor, isBold: false)]
        }
        
        var segments: [ANSISegment] = []
        var currentColor = Self.defaultTextColor
        var currentBold = false
        
        let pattern = #"\x1b\[([0-9;]*)m"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [ANSISegment(text: line, color: Self.defaultTextColor, isBold: false)]
        }
        
        let nsString = line as NSString
        var lastLocation = 0
        let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            let matchRange = match.range
            if matchRange.location > lastLocation {
                let textChunk = nsString.substring(with: NSRange(location: lastLocation, length: matchRange.location - lastLocation))
                if !textChunk.isEmpty {
                    segments.append(ANSISegment(text: textChunk, color: currentColor, isBold: currentBold))
                }
            }
            
            // Decodificar el código de formato ANSI
            if match.numberOfRanges > 1 {
                let codeRange = match.range(at: 1)
                let codesString = nsString.substring(with: codeRange)
                let codes = codesString.split(separator: ";").compactMap { Int($0) }
                
                if codes.isEmpty || codes.contains(0) {
                    currentColor = Self.defaultTextColor
                    currentBold = false
                }
                
                for code in codes {
                    switch code {
                    case 0:
                        currentColor = Self.defaultTextColor
                        currentBold = false
                    case 1:
                        currentBold = true
                    case 30: currentColor = Self.blackColor
                    case 31, 91: currentColor = Self.redColor
                    case 32, 92: currentColor = Self.greenColor
                    case 33, 93: currentColor = Self.yellowColor
                    case 34, 94: currentColor = Self.blueColor
                    case 35, 95: currentColor = Self.magentaColor
                    case 36, 96: currentColor = Self.cyanColor
                    case 37, 97: currentColor = Self.whiteColor
                    case 39: currentColor = Self.defaultTextColor
                    default:
                        break
                    }
                }
            }
            
            lastLocation = matchRange.location + matchRange.length
        }
        
        if lastLocation < nsString.length {
            let remaining = nsString.substring(from: lastLocation)
            if !remaining.isEmpty {
                segments.append(ANSISegment(text: remaining, color: currentColor, isBold: currentBold))
            }
        }
        
        return segments.isEmpty ? [ANSISegment(text: line, color: Self.defaultTextColor, isBold: false)] : segments
    }
}
