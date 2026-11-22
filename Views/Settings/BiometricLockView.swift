import SwiftUI

/// Pantalla de bloqueo biométrico (Face ID / Touch ID)
struct BiometricLockView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    
    var body: some View {
        ZStack {
            // Desenfoque profundo sobre la interfaz
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            Color(red: 0.04, green: 0.05, blue: 0.07).opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image("AppIcon-1024")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                VStack(spacing: 6) {
                    Text("LynxNodes Bloqueado")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Usa \(BiometricAuthManager.shared.biometryName) para desbloquear la aplicación.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.60))
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
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.20, green: 0.55, blue: 1.0),
                                Color(red: 0.15, green: 0.40, blue: 0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
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
