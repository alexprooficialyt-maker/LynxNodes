import SwiftUI

@main
struct LynxNodesApp: App {
    @StateObject private var appEnv = AppEnvironment()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !appEnv.isConfigured {
                    LoginView()
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .transition(.opacity)
                    
                    // Capa de bloqueo con Face ID si está activada y bloqueada
                    if !appEnv.isBiometricallyUnlocked {
                        BiometricLockView()
                            .transition(.opacity)
                            .zIndex(999)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appEnv.isConfigured)
            .animation(.easeInOut(duration: 0.25), value: appEnv.isBiometricallyUnlocked)
            .environmentObject(appEnv)
            .preferredColorScheme(.dark) // Modo oscuro permanente y refinado
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background {
                    appEnv.lockApp()
                }
            }
        }
    }
}
