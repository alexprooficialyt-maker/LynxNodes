import SwiftUI

/// Vista de consola de comandos interactiva en tiempo real con WebSocket (Tema LynxNodes Liquid Glass)
struct ConsoleView: View {
    @ObservedObject var viewModel: ServerConsoleViewModel
    @AppStorage("lynxnodes_console_font_size") private var consoleFontSize: Double = 12.0
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            
            // Barra de Métricas en Vivo desde WebSocket
            liveStatsBar()
            
            // Botones de Energía
            PowerControlsView(viewModel: viewModel)
            
            // Área de Terminal / Logs en Negro Profundo
            ZStack(alignment: .bottomTrailing) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 3) {
                            if viewModel.logs.isEmpty {
                                Text("Conectando con la consola de Wings...")
                                    .font(.system(size: CGFloat(consoleFontSize), weight: .regular, design: .monospaced))
                                    .foregroundColor(Color(white: 0.45))
                                    .padding(.top, 24)
                                    .padding(.horizontal, 12)
                            } else {
                                ForEach(viewModel.logs) { entry in
                                    HStack(alignment: .top, spacing: 0) {
                                        ForEach(entry.segments) { segment in
                                            Text(segment.text)
                                                .font(.system(
                                                    size: CGFloat(consoleFontSize),
                                                    weight: segment.isBold ? .bold : .regular,
                                                    design: .monospaced
                                                ))
                                                .foregroundColor(segment.color)
                                        }
                                    }
                                    .id(entry.id)
                                }
                            }
                        }
                        .padding(12)
                    }
                    .background(Color(red: 0.04, green: 0.04, blue: 0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 0.8)
                    )
                    .onChange(of: viewModel.logs.count) {
                        if viewModel.autoScrollEnabled, let lastId = viewModel.logs.last?.id {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                
                // Botones flotantes de herramientas de consola (Copiar, Auto-scroll, Limpiar)
                HStack(spacing: 8) {
                    // Botón Auto-scroll
                    Button {
                        viewModel.autoScrollEnabled.toggle()
                        HapticFeedback.light()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.autoScrollEnabled ? "arrow.down.to.line.circle.fill" : "arrow.down.to.line.circle")
                                .font(.system(size: 13))
                            Text(viewModel.autoScrollEnabled ? "Auto" : "Pausa")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .foregroundColor(viewModel.autoScrollEnabled ? Color(red: 1.0, green: 0.75, blue: 0.0) : Color(white: 0.60))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                        )
                    }
                    
                    // Botón Copiar Logs
                    Button {
                        viewModel.copyAllLogs()
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                            )
                    }
                    
                    // Botón Limpiar
                    Button {
                        viewModel.clearLogs()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.70))
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                            )
                    }
                }
                .padding(10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        // BARRA DE ENTRADA DE COMANDOS FIJA Y ACCESIBLE: Sube automáticamente con el teclado
        .safeAreaInset(edge: .bottom) {
            commandInputBar()
        }
    }
    
    // MARK: - Barra de Entrada de Comandos (Alto contraste, teclado respetado)
    
    private func commandInputBar() -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(">")
                    .font(.system(size: 15, weight: .black, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.0))
                
                TextField("Enviar comando...", text: $viewModel.commandInput)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.white)
                    .focused($isInputFocused)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onSubmit {
                        viewModel.sendCurrentCommand()
                    }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(red: 0.08, green: 0.09, blue: 0.13)) // #141620
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isInputFocused ? Color(red: 1.0, green: 0.75, blue: 0.0).opacity(0.6) : Color.white.opacity(0.14), lineWidth: 0.8)
            )
            
            // Botón Enviar en Amarillo Lynx
            Button {
                viewModel.sendCurrentCommand()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 13, weight: .black))
                }
                .foregroundColor(.black)
                .frame(width: 42, height: 42)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.75, blue: 0.00),
                            Color(red: 1.00, green: 0.65, blue: 0.00)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.35), radius: 6, y: 2)
            }
            .disabled(viewModel.commandInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(red: 0.05, green: 0.06, blue: 0.09))
    }
    
    // MARK: - Barra de Métricas en Vivo
    
    private func liveStatsBar() -> some View {
        GlassCard(cornerRadius: 16, padding: 12) {
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    metricItem(label: "CPU", value: viewModel.stats.formattedCpu, highlightColor: Color(red: 1.0, green: 0.75, blue: 0.0))
                    metricItem(label: "RAM", value: "\(viewModel.stats.formattedMemoryUsed) / \(viewModel.stats.formattedMemoryLimit)", highlightColor: .white)
                    metricItem(label: "Disco", value: viewModel.stats.formattedDisk, highlightColor: .white)
                    metricItem(label: "Uptime", value: viewModel.stats.formattedUptime, highlightColor: Color(red: 0.0, green: 0.90, blue: 1.0))
                }
                
                // Tráfico de red
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 9))
                            .foregroundColor(Color(red: 0.13, green: 0.77, blue: 0.37))
                        Text(viewModel.stats.formattedNetworkRx)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(white: 0.70))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 9))
                            .foregroundColor(Color(red: 0.0, green: 0.90, blue: 1.0))
                        Text(viewModel.stats.formattedNetworkTx)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(white: 0.70))
                    }
                }
            }
        }
    }
    
    private func metricItem(label: String, value: String, highlightColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(Color(white: 0.50))
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(highlightColor)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
