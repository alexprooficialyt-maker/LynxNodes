import SwiftUI

/// Barra de navegación inferior flotante estilo cápsula con efecto Liquid Glass en Negro y Amarillo Lynx,
/// animaciones fluidas con resorte (spring) y feedback háptico al cambiar de pestaña.
struct FloatingTabBar: View {
    @Binding var selectedTab: AppEnvironment.TabItem
    @Namespace private var tabAnimationNamespace
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(AppEnvironment.TabItem.allCases) { tab in
                let isSelected = selectedTab == tab
                
                Button {
                    if selectedTab != tab {
                        HapticFeedback.light()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
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
                                .foregroundColor(LynxTheme.goldBright)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                    .padding(.horizontal, isSelected ? 16 : 14)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(LynxTheme.goldGlassGradient)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [LynxTheme.goldBright.opacity(0.6), LynxTheme.gold.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 0.8
                                            )
                                    )
                                    .shadow(color: LynxTheme.goldGlow, radius: 8, y: 2)
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
        .liquidGlass(cornerRadius: 32, strokeOpacity: 0.20, fillOpacity: 0.70, shadowRadius: 18)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func tabIcon(for tab: AppEnvironment.TabItem, isSelected: Bool) -> some View {
        let color: Color = isSelected ? LynxTheme.goldBright : Color(white: 0.55)
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
