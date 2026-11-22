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
            
            // Barra inferior flotante estilo Liquid Glass
            FloatingTabBar(selectedTab: $appEnv.selectedTab)
        }
    }
}
