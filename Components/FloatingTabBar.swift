import SwiftUI

/// Barra de navegación inferior flotante estilo cápsula focal Apple iOS 26 Liquid Glass
/// Deslizamiento líquido con matchedGeometryEffect, animaciones spring fluidas y respuesta háptica.
struct FloatingTabBar: View {
    @Binding var selectedTab: AppEnvironment.TabItem
    @Namespace private var tabAnimationNamespace
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppEnvironment.TabItem.allCases) { tab in
                let isSelected = selectedTab == tab
                
                Button {
                    if selectedTab != tab {
                        HapticFeedback.light()
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.72)) {
                            selectedTab = tab
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        tabIcon(for: tab, isSelected: isSelected)
                            .frame(width: 22, height: 22)
                        
                        if isSelected {
                            Text(tab.title)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        }
                    }
                    .padding(.horizontal, isSelected ? 16 : 14)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                SmartTheme.blue.opacity(0.35),
                                                SmartTheme.blueDark.opacity(0.18)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [
                                                        SmartTheme.blueBright.opacity(0.7),
                                                        Color.white.opacity(0.2),
                                                        SmartTheme.blue.opacity(0.3)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 0.8
                                            )
                                    )
                                    .shadow(color: SmartTheme.blueGlow, radius: 10, y: 3)
                                    .matchedGeometryEffect(id: "activeTabIndicator", in: tabAnimationNamespace)
                            }
                        }
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(6)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(red: 0.05, green: 0.06, blue: 0.09).opacity(0.78))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.30), location: 0.0),
                            .init(color: Color.white.opacity(0.08), location: 0.45),
                            .init(color: SmartTheme.blue.opacity(0.20), location: 0.85),
                            .init(color: Color.white.opacity(0.04), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
        .shadow(color: Color.black.opacity(0.55), radius: 24, x: 0, y: 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func tabIcon(for tab: AppEnvironment.TabItem, isSelected: Bool) -> some View {
        let color: Color = isSelected ? SmartTheme.blueBright : SmartTheme.textSecondary
        switch tab {
        case .home:
            CustomIcon(type: .home, size: 20, color: color)
        case .servers:
            CustomIcon(type: .servers, size: 20, color: color)
        case .files:
            CustomIcon(type: .files, size: 20, color: color)
        case .settings:
            CustomIcon(type: .settings, size: 20, color: color)
        }
    }
}
