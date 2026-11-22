import SwiftUI

/// Pestaña Ajustes: Gestión de conexión, seguridad con Face ID y preferencias (Tema Negro y Amarillo)
struct SettingsView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Sección: Conexión con Pterodactyl
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Conexión con LynxNodes")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(LynxTheme.goldBright)
                            .padding(.horizontal, 4)
                        
                        GlassCard(cornerRadius: 18, padding: 16) {
                            VStack(spacing: 14) {
                                // URL del Panel
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("URL del Panel")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(LynxTheme.textSecondary)
                                    
                                    HStack {
                                        TextField("https://panel.lynxnodes.es", text: $viewModel.panelUrl)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .font(.system(size: 13, design: .monospaced))
                                            .foregroundColor(.white)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                        
                                        Button("Guardar") {
                                            viewModel.savePanelUrl()
                                        }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(LynxTheme.goldBright)
                                    }
                                    .padding(10)
                                    .background(Color.white.opacity(0.04))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.08))
                                
                                // API Key enmascarada
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Client API Key (Guardada en Keychain)")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(LynxTheme.textSecondary)
                                        
                                        Spacer()
                                        
                                        Button("Modificar") {
                                            viewModel.newApiKeyInput = ""
                                            viewModel.showApiKeyUpdateSheet = true
                                        }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(LynxTheme.goldBright)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "key.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(LynxTheme.gold)
                                        
                                        Text(viewModel.maskedApiKey)
                                            .font(.system(size: 13, design: .monospaced))
                                            .foregroundColor(LynxTheme.goldBright)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "checkmark.shield.fill")
                                            .font(.system(size: 13))
                                            .foregroundColor(Color(red: 0.22, green: 0.85, blue: 0.45))
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
                            .foregroundColor(LynxTheme.goldBright)
                            .padding(.horizontal, 4)
                        
                        GlassCard(cornerRadius: 18, padding: 16) {
                            Toggle(isOn: Binding(
                                get: { viewModel.isBiometricsEnabled },
                                set: { viewModel.toggleBiometrics($0) }
                            )) {
                                HStack(spacing: 12) {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 18))
                                        .foregroundColor(LynxTheme.goldBright)
                                        .frame(width: 28, height: 28)
                                        .background(LynxTheme.gold.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Bloquear con Face ID")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text("Solicitar autenticación al abrir la app")
                                            .font(.system(size: 11))
                                            .foregroundColor(LynxTheme.textSecondary)
                                    }
                                }
                            }
                            .tint(LynxTheme.gold)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Sección: Preferencias de Consola
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Consola")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(LynxTheme.goldBright)
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
                                            .foregroundColor(LynxTheme.goldBright)
                                    }
                                    
                                    Slider(
                                        value: Binding(
                                            get: { viewModel.consoleFontSize },
                                            set: { viewModel.updateConsoleFontSize($0) }
                                        ),
                                        in: 10...18,
                                        step: 1
                                    )
                                    .tint(LynxTheme.gold)
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
                                            .foregroundColor(LynxTheme.textSecondary)
                                    }
                                }
                                .tint(LynxTheme.gold)
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
                        .foregroundColor(Color(red: 0.95, green: 0.35, blue: 0.35))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.95, green: 0.35, blue: 0.35).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color(red: 0.95, green: 0.35, blue: 0.35).opacity(0.25), lineWidth: 0.8)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Info de versión
                    VStack(spacing: 4) {
                        Text("LynxNodes v1.0.0 (Gold & Obsidian Edition)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(LynxTheme.gold.opacity(0.7))
                        Text("panel.lynxnodes.es")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(LynxTheme.textMuted)
                    }
                    .padding(.top, 12)
                    
                    Spacer().frame(height: 100)
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
                                .foregroundColor(LynxTheme.textSecondary)
                            
                            SecureField("Pega tu clave (ptlc_...)", text: $viewModel.newApiKeyInput)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(LynxTheme.gold.opacity(0.4), lineWidth: 0.8)
                                )
                                .autocapitalization(.none)
                        }
                        
                        Button {
                            viewModel.updateApiKey()
                        } label: {
                            Text("Guardar Nueva Clave en Keychain")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(LynxTheme.goldGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: LynxTheme.gold.opacity(0.4), radius: 8, y: 2)
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
                            .foregroundColor(LynxTheme.textSecondary)
                        }
                    }
                }
            }
        }
    }
}
