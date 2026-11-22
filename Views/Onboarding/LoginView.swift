import SwiftUI

/// Pantalla de configuración inicial y conexión con Pterodactyl en LynxNodes (Tema Negro y Amarillo)
struct LoginView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    @StateObject private var viewModel = AuthViewModel()
    @State private var isShowingUrlEditor = false
    
    var body: some View {
        ZStack {
            // Fondo Negro OLED
            LynxTheme.bgBlack
                .ignoresSafeArea()
            
            // Halo de luz ámbar/dorado de LynxNodes en la parte superior
            Circle()
                .fill(LynxTheme.gold.opacity(0.18))
                .blur(radius: 100)
                .frame(width: 340, height: 340)
                .offset(y: -220)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 36)
                    
                    // Logo / Icono oficial de la App
                    VStack(spacing: 14) {
                        Image("AppIcon-1024")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 92, height: 92)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [LynxTheme.goldBright.opacity(0.6), Color.white.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.2
                                    )
                            )
                            .shadow(color: LynxTheme.gold.opacity(0.35), radius: 16, x: 0, y: 8)
                        
                        HStack(spacing: 6) {
                            Text("LYNX")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(LynxTheme.goldBright)
                            Text("NODES")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Text("Gestor nativo de servidores Pterodactyl")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(LynxTheme.textSecondary)
                    }
                    
                    // Tarjeta de Conexión Liquid Glass
                    GlassCard(cornerRadius: 24, padding: 22) {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // Selector de URL del Panel
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Panel LynxNodes")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(LynxTheme.textSecondary)
                                    
                                    Spacer()
                                    
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            isShowingUrlEditor.toggle()
                                        }
                                    } label: {
                                        Text(isShowingUrlEditor ? "Listo" : "Editar URL")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(LynxTheme.goldBright)
                                    }
                                }
                                
                                if isShowingUrlEditor {
                                    TextField("https://panel.lynxnodes.es", text: $viewModel.panelUrl)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .font(.system(size: 14, design: .monospaced))
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(LynxTheme.gold.opacity(0.4), lineWidth: 0.8)
                                        )
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(LynxTheme.goldBright)
                                            .frame(width: 8, height: 8)
                                            .shadow(color: LynxTheme.goldBright.opacity(0.6), radius: 4)
                                        
                                        Text(viewModel.panelUrl)
                                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.04))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.08))
                            
                            // Campo de API Key (Manual por el usuario, sin hardcode)
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Client API Key")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(LynxTheme.textSecondary)
                                    
                                    Spacer()
                                    
                                    Text("Privada y local")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(LynxTheme.gold.opacity(0.8))
                                }
                                
                                SecureField("Pega tu clave (ptlc_...)", text: $viewModel.apiKey)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(14)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(viewModel.apiKey.isEmpty ? Color.white.opacity(0.12) : LynxTheme.gold.opacity(0.5), lineWidth: 0.8)
                                    )
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "key.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(LynxTheme.gold)
                                    Text("Panel > Account > API Credentials > Create API Key")
                                        .font(.system(size: 11))
                                        .foregroundColor(LynxTheme.textMuted)
                                }
                            }
                            
                            // Botón "Probar y Conectar" en Amarillo Lynx
                            Button {
                                Task {
                                    await viewModel.testAndConnect(appEnv: appEnv)
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                            .scaleEffect(0.9)
                                    } else {
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    
                                    Text(viewModel.isLoading ? "Validando en LynxNodes..." : "Probar y Conectar")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(LynxTheme.goldGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                                )
                                .shadow(color: LynxTheme.gold.opacity(0.45), radius: 12, y: 4)
                            }
                            .disabled(viewModel.isLoading)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Aviso de Seguridad Local Keychain
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 14))
                            .foregroundColor(LynxTheme.gold)
                            .padding(.top, 2)
                        
                        Text("Tu clave de cliente no está grabada en la app. Se guardará de manera cifrada exclusivamente en el Keychain nativo de tu iPhone para que solo tú tengas acceso.")
                            .font(.system(size: 12))
                            .foregroundColor(LynxTheme.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(.horizontal, 28)
                    
                    Spacer()
                }
            }
        }
        .alert("Error de Conexión", isPresented: $viewModel.showError) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "No se pudo conectar con el panel.")
        }
    }
}
