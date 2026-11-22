import SwiftUI

/// Pantalla de bloqueo biométrico (Face ID / Touch ID)
/// Estética Apple iOS 26 Liquid Glass en Negro, Azul y Blanco
struct BiometricLockView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            SmartTheme.bgBlack.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(SmartTheme.blue.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: SmartTheme.blue.opacity(0.3), radius: 10)
                
                VStack(spacing: 6) {
                    Text("SmartBot Protegido")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Usa \(BiometricAuthManager.shared.biometryName) para desbloquear la aplicación.")
                        .font(.system(size: 13))
                        .foregroundColor(SmartTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Button {
                    Task {
                        _ = await appEnv.unlockWithBiometrics()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "faceid")
                            .font(.system(size: 20))
                        Text("Desbloquear")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(SmartTheme.blueGradient)
                    .clipShape(Capsule())
                    .shadow(color: SmartTheme.blue.opacity(0.4), radius: 8, y: 2)
                }
            }
        }
        .onAppear {
            Task {
                _ = await appEnv.unlockWithBiometrics()
            }
        }
    }
}
