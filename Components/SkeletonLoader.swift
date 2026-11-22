import SwiftUI

/// Efecto de carga esqueleto (Shimmer) sobrio y nativo
struct SkeletonLoader: View {
    @State private var phase: CGFloat = -1.0
    
    var body: some View {
        VStack(spacing: 14) {
            ForEach(0..<3) { _ in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 140, height: 18)
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 60, height: 20)
                    }
                    
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 90, height: 12)
                    
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 6)
                    }
                }
                .padding(16)
                .liquidGlass(cornerRadius: 18)
            }
        }
        .padding(.horizontal, 16)
        .opacity(0.85)
    }
}
