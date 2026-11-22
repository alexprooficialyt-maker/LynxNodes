import SwiftUI

/// Pestaña Ajustes: Gestión de conexión, seguridad con Face ID y preferencias
/// Estética Apple iOS 26 Liquid Glass en Negro, Azul y Blanco
struct SettingsView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Sección: Credenciales y Clave API
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Credenciales API")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(SmartTheme.blue)
                            .padding(.horizontal, 4)
                        
                        GlassCard(cornerRadius: 18, padding: 16) {
                            VStack(spacing: 14) {
                                // API Key enmascarada
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Client API Key (Guardada en Keychain)")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(SmartTheme.textSecondary)
                                        
                                        Spacer()
                                        
                                        Button("Modificar") {
                                            viewModel.newApiKeyInput = ""
                                            viewModel.showApiKeyUpdateSheet = true
                                        }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(SmartTheme.blue)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "key.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(SmartTheme.blue)
                                        
                                        Text(viewModel.maskedApiKey)
                                            .font(.system(size: 13, design: .monospaced))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "checkmark.shield.fill")
                                            .font(.system(size: 13))
                                            .foregroundColor(SmartTheme.statusRunning)
                                    }
                                    .padding(10)
                                    .background(Color.white.opacity(0.04))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Sección: Seguridad
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Seguridad y Acceso")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(SmartTheme.blue)
                            .padding(.horizontal, 4)
                        
                        GlassCard(cornerRadius: 18, padding: 16) {
                            Toggle(isOn: Binding(
                                get: { viewModel.isBiometricsEnabled },
                                set: { viewModel.toggleBiometrics($0) }
                            )) {
                                HStack(spacing: 12) {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 18))
                                        .foregroundColor(SmartTheme.blue)
                                        .frame(width: 28, height: 28)
                                        .background(SmartTheme.blue.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Bloquear con Face ID")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text("Solicitar autenticación al abrir la app")
                                            .font(.system(size: 11))
                                            .foregroundColor(SmartTheme.textSecondary)
                                    }
                                }
                            }
                            .tint(SmartTheme.blue)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Sección: Preferencias de Consola
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Consola")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(SmartTheme.blue)
                            .padding(.horizontal, 4)
                        
                        GlassCard(cornerRadius: 18, padding: 16) {
                            VStack(spacing: 16) {
                                // Tamaño de fuente
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Tamaño de Fuente")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(viewModel.consoleFontSize)) pt")
                                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                            .foregroundColor(SmartTheme.blue)
                                    }
                                    
                                    Slider(
                                        value: Binding(
                                            get: { viewModel.consoleFontSize },
                                            set: { viewModel.updateConsoleFontSize($0) }
                                        ),
                                        in: 10...18,
                                        step: 1
                                    )
                                    .tint(SmartTheme.blue)
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.08))
                                
                                // Auto-scroll por defecto
                                Toggle(isOn: Binding(
                                    get: { viewModel.autoScrollDefault },
                                    set: { viewModel.updateAutoScroll($0) }
                                )) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Auto-scroll Activo")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white)
                                        Text("Bajar automáticamente con cada nueva línea de log")
                                            .font(.system(size: 11))
                                            .foregroundColor(SmartTheme.textSecondary)
                                    }
                                }
                                .tint(SmartTheme.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Botón Cerrar Sesión / Desconectar
                    Button {
                        viewModel.showLogoutAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 14))
                            Text("Desconectar Cuenta")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(SmartTheme.statusOffline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(SmartTheme.statusOffline.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(SmartTheme.statusOffline.opacity(0.25), lineWidth: 0.8)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Info de versión SmartBot
                    VStack(spacing: 4) {
                        Text("SmartBot")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Sistema de Control de Hosting")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(SmartTheme.textSecondary)
                    }
                    .padding(.top, 12)
                    
                    // Margen inferior para que nunca quede tapado por el menú flotante
                    Spacer().frame(height: 130)
                }
                .padding(.top, 16)
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .liquidDarkBackground()
            .confirmationDialog(
                "¿Deseas desconectar tu cuenta?",
                isPresented: $viewModel.showLogoutAlert,
                titleVisibility: .visible
            ) {
                Button("Desconectar y Borrar Clave", role: .destructive) {
                    appEnv.logout()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Se eliminará la API Key guardada de forma segura en tu Keychain.")
            }
            // Hoja para actualizar API Key
            .sheet(isPresented: $viewModel.showApiKeyUpdateSheet) {
                NavigationStack {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nueva Client API Key")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(SmartTheme.textSecondary)
                            
                            SecureField("Introduce tu clave (ptlc_...)", text: $viewModel.newApiKeyInput)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(SmartTheme.blue.opacity(0.5), lineWidth: 0.8)
                                )
                                .autocapitalization(.none)
                        }
                        
                        Button {
                            viewModel.updateApiKey()
                        } label: {
                            Text("Guardar en Keychain")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(SmartTheme.blueGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: SmartTheme.blue.opacity(0.4), radius: 8, y: 2)
                        }
                        .disabled(viewModel.newApiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        Spacer()
                    }
                    .padding(20)
                    .liquidDarkBackground()
                    .navigationTitle("Actualizar API Key")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancelar") {
                                viewModel.showApiKeyUpdateSheet = false
                            }
                            .foregroundColor(SmartTheme.textSecondary)
                        }
                    }
                }
            }
        }
    }
}
