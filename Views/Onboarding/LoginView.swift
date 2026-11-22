import SwiftUI

/// Pantalla de configuración inicial y conexión con Pterodactyl en LynxNodes
/// Diseño premium con Icono.jpg (AppLogo), Liquid Glass y estética oficial Amarillo & Negro
struct LoginView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    @StateObject private var viewModel = AuthViewModel()
    @State private var isShowingUrlEditor = false
    @State private var showKeyPlain = false
    
    var body: some View {
        ZStack {
            // Fondo Negro Obsidiana Lynx
            Color(red: 0.04, green: 0.05, blue: 0.07)
                .ignoresSafeArea()
            
            // Halo sutil de luz ámbar/dorado detrás del logo
            Circle()
                .fill(Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.16))
                .blur(radius: 90)
                .frame(width: 300, height: 300)
                .offset(y: -210)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 26) {
                    Spacer().frame(height: 28)
                    
                    // Logo oficial (Icono.jpg) con acabado de esquinas suaves iOS y resplandor
                    VStack(spacing: 14) {
                        ZStack {
                            // Brillo ambiental
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.30))
                                .frame(width: 96, height: 96)
                                .blur(radius: 12)
                            
                            Image("AppLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 92, height: 92)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 1.0, green: 0.75, blue: 0.0).opacity(0.7),
                                                    Color.white.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.2
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.55), radius: 14, x: 0, y: 8)
                        }
                        
                        // Título con degradado Amarillo/Naranja LynxNodes
                        VStack(spacing: 4) {
                            Text("LynxNodes")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.00, green: 0.76, blue: 0.05), // #FFC20D
                                            Color(red: 1.00, green: 0.58, blue: 0.00)  // #FF9400
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Panel de Control")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color(white: 0.65))
                        }
                    }
                    
                    // Tarjeta Liquid Glass de Conexión
                    GlassCard(cornerRadius: 24, padding: 22) {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // Selector de URL del Panel
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Panel de Servidores")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(white: 0.65))
                                    
                                    Spacer()
                                    
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            isShowingUrlEditor.toggle()
                                        }
                                    } label: {
                                        Text(isShowingUrlEditor ? "Listo" : "Editar URL")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.0))
                                    }
                                }
                                
                                if isShowingUrlEditor {
                                    TextField("https://panel.lynxnodes.es", text: $viewModel.panelUrl)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .font(.system(size: 14, design: .monospaced))
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color(red: 0.07, green: 0.08, blue: 0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.4), lineWidth: 0.8)
                                        )
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color(red: 0.13, green: 0.77, blue: 0.37))
                                            .frame(width: 8, height: 8)
                                            .shadow(color: Color(red: 0.13, green: 0.77, blue: 0.37).opacity(0.8), radius: 4)
                                        
                                        Text(viewModel.panelUrl)
                                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color(red: 0.07, green: 0.08, blue: 0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
                                    )
                                }
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.08))
                            
                            // Campo de API Key con Botón Pegar y Ver/Ocultar
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Client API Key")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(white: 0.65))
                                    
                                    Spacer()
                                    
                                    // Botón para pegar directamente del portapapeles
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
                                                .font(.system(size: 11, weight: .bold))
                                        }
                                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.0))
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 4)
                                        .background(Color(red: 1.0, green: 0.75, blue: 0.0).opacity(0.14))
                                        .clipShape(Capsule())
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    if showKeyPlain {
                                        TextField("Pega tu clave (ptlc_...)", text: $viewModel.apiKey)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .font(.system(size: 13, design: .monospaced))
                                            .foregroundColor(.white)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    } else {
                                        SecureField("Pega tu clave (ptlc_...)", text: $viewModel.apiKey)
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
                                            .foregroundColor(Color(white: 0.45))
                                    }
                                }
                                .padding(14)
                                .background(Color(red: 0.07, green: 0.08, blue: 0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(viewModel.apiKey.isEmpty ? Color.white.opacity(0.12) : Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.55), lineWidth: 0.8)
                                )
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "key.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.0))
                                    Text("Generada en: Account > API Credentials > Create API Key")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(white: 0.45))
                                }
                            }
                            
                            // Botón "Conectar" oficial LynxNodes
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
                                            .font(.system(size: 14, weight: .black))
                                    }
                                    
                                    Text(viewModel.isLoading ? "Conectando con LynxNodes..." : "Conectar")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.00, green: 0.75, blue: 0.00), // #FFC000
                                            Color(red: 1.00, green: 0.65, blue: 0.00)  // #FFA600
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.35), lineWidth: 0.8)
                                )
                                .shadow(color: Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.40), radius: 12, y: 4)
                            }
                            .disabled(viewModel.isLoading)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Aviso de Seguridad Keychain
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.0))
                            .padding(.top, 2)
                        
                        Text("Tu clave de cliente se almacena de forma encriptada en el Keychain de tu iPhone. No se envía a ningún servidor externo aparte de panel.lynxnodes.es.")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.55))
                            .lineSpacing(2)
                    }
                    .padding(.horizontal, 26)
                    
                    Spacer().frame(height: 30)
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
