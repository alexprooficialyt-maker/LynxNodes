import SwiftUI

/// Vista principal de navegación con Floating Tab Bar estilo Liquid Glass
struct MainTabView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Contenedor de Vistas
            TabView(selection: $appEnv.selectedTab) {
                DashboardView()
                    .tag(AppEnvironment.TabItem.home)
                
                ServerListView()
                    .tag(AppEnvironment.TabItem.servers)
                
                DirectFilesTabView()
                    .tag(AppEnvironment.TabItem.files)
                
                SettingsView()
                    .tag(AppEnvironment.TabItem.settings)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Barra inferior flotante estilo Liquid Glass (se oculta al entrar a un servidor o consola)
            if !appEnv.hideTabBar {
                FloatingTabBar(selectedTab: $appEnv.selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: appEnv.hideTabBar)
    }
}
