import SwiftUI

/// Visor y editor de archivos de texto y código (.env, .json, .yml, .js, .txt, etc.)
/// Estética Apple iOS 26 Liquid Glass en Negro, Azul y Blanco
struct FileEditorView: View {
    let fileName: String
    @Binding var content: String
    let onSave: () async -> Void
    let isSaving: Bool
    let saveSuccess: Bool
    
    @Environment(\.dismiss) private var dismiss
    @State private var originalContent: String = ""
    @State private var showDiscardAlert: Bool = false
    
    var hasChanges: Bool {
        content != originalContent
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Barra de herramientas superior
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 13))
                            .foregroundColor(SmartTheme.blue)
                        
                        Text(fileName)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if saveSuccess {
                        Text("Guardado")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(SmartTheme.statusRunning)
                            .transition(.opacity)
                    }
                    
                    // Botón Guardar en Azul SmartBot
                    Button {
                        Task {
                            await onSave()
                        }
                    } label: {
                        HStack(spacing: 5) {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            
                            Text("Guardar")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(SmartTheme.blueGradient)
                        .clipShape(Capsule())
                        .shadow(color: SmartTheme.blue.opacity(0.35), radius: 6, y: 2)
                    }
                    .disabled(isSaving || !hasChanges)
                    .opacity(hasChanges ? 1.0 : 0.45)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(SmartTheme.bgElevated)
                
                Divider()
                    .background(Color.white.opacity(0.10))
                
                // Editor de texto en OLED Black
                TextEditor(text: $content)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(red: 0.95, green: 0.96, blue: 0.98))
                    .scrollContentBackground(.hidden)
                    .background(SmartTheme.bgBlack)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(8)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        if hasChanges {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(SmartTheme.textSecondary)
                }
            }
            .onAppear {
                originalContent = content
            }
            .alert("Cambios sin guardar", isPresented: $showDiscardAlert) {
                Button("Descartar cambios", role: .destructive) {
                    dismiss()
                }
                Button("Seguir editando", role: .cancel) {}
            } message: {
                Text("Has realizado modificaciones en el archivo que no han sido guardadas en el panel.")
            }
        }
    }
}
