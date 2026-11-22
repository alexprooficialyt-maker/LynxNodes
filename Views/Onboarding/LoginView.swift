import SwiftUI

/// Pantalla de bienvenida y autenticación segura de SmartBot
/// Diseño 100% Apple iOS 26 Liquid Glass en Negro, Azul y Blanco
struct LoginView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    @StateObject private var viewModel = AuthViewModel()
    @State private var showKeyPlain = false
    
    var body: some View {
        ZStack {
            // Fondo Negro Puro
            SmartTheme.bgBlack
                .ignoresSafeArea()
            
            // Halo de luz azul Apple sutil en el fondo
            Circle()
                .fill(SmartTheme.blue.opacity(0.18))
                .blur(radius: 100)
                .frame(width: 320, height: 320)
                .offset(y: -220)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 34)
                    
                    // Logo SmartBot (LogoSmart.png) con esquinas continuas y borde líquido
                    VStack(spacing: 16) {
                        ZStack {
                            // Brillo azul ambiental
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(SmartTheme.blue.opacity(0.35))
                                .frame(width: 100, height: 100)
                                .blur(radius: 16)
                            
                            Image("AppLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 96, height: 96)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    SmartTheme.blueBright.opacity(0.8),
                                                    Color.white.opacity(0.3),
                                                    SmartTheme.blueDark.opacity(0.4)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.2
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.7), radius: 18, x: 0, y: 10)
                        }
                        
                        // Título y Subtítulo SmartBot
                        VStack(spacing: 5) {
                            Text("SmartBot")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Sistema de Control de Hosting")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(SmartTheme.textSecondary)
                                .tracking(0.3)
                        }
                    }
                    
                    // Tarjeta Liquid Glass para la API Key (URL oculta internamente)
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Client API Key")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(SmartTheme.textSecondary)
                                
                                Spacer()
                                
                                // Botón para pegar del portapapeles
                                Button {
                                    if let pasted = UIPasteboard.general.string {
                                        viewModel.apiKey = pasted.trimmingCharacters(in: .whitespacesAndNewlines)
                                        HapticFeedback.light()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.on.clipboard")
                                            .font(.system(size: 11))
                                        Text("Pegar")
                                            .font(.system(size: 11, weight: .semibold))
                                    }
                                    .foregroundColor(SmartTheme.blue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(SmartTheme.blue.opacity(0.12))
                                    .clipShape(Capsule())
                                }
                            }
                            
                            HStack(spacing: 10) {
                                Image(systemName: "key.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(viewModel.apiKey.isEmpty ? SmartTheme.textMuted : SmartTheme.blue)
                                
                                if showKeyPlain {
                                    TextField("Introduce tu clave (ptlc_...)", text: $viewModel.apiKey)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.white)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("Introduce tu clave (ptlc_...)", text: $viewModel.apiKey)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.white)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                
                                Button {
                                    showKeyPlain.toggle()
                                } label: {
                                    Image(systemName: showKeyPlain ? "eye.slash" : "eye")
                                        .font(.system(size: 13))
                                        .foregroundColor(SmartTheme.textMuted)
                                }
                            }
                            .padding(14)
                            .background(Color(red: 0.05, green: 0.06, blue: 0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        viewModel.apiKey.isEmpty ? Color.white.opacity(0.10) : SmartTheme.blue.opacity(0.6),
                                        lineWidth: 0.8
                                    )
                            )
                            
                            Text("Genera tu clave en: Cuenta > Credenciales API")
                                .font(.system(size: 11))
                                .foregroundColor(SmartTheme.textMuted)
                        }
                        
                        // Botón de Conexión Azul SmartBot
                        Button {
                            Task {
                                await viewModel.testAndConnect(appEnv: appEnv)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                
                                Text(viewModel.isLoading ? "Conectando..." : "Conectar")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [
                                        SmartTheme.blueBright,
                                        SmartTheme.blueDark
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                            )
                            .shadow(color: SmartTheme.blue.opacity(0.40), radius: 12, y: 4)
                        }
                        .disabled(viewModel.isLoading || viewModel.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(viewModel.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                    }
                    .padding(22)
                    .background(SmartTheme.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
                    )
                    .padding(.horizontal, 20)
                    
                    // Aviso de Seguridad en Keychain
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 14))
                            .foregroundColor(SmartTheme.blue)
                            .padding(.top, 1)
                        
                        Text("Tu clave se almacena cifrada en el Keychain de tu iPhone con aislamiento de hardware del Secure Enclave.")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(SmartTheme.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(.horizontal, 28)
                    
                    Spacer().frame(height: 30)
                }
            }
        }
        .alert("Error de Conexión", isPresented: $viewModel.showError) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "No se pudo validar la clave API.")
        }
    }
}
