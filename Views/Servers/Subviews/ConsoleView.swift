import SwiftUI

/// Vista de consola de comandos interactiva en tiempo real con WebSocket (Tema Negro y Amarillo)
struct ConsoleView: View {
    @ObservedObject var viewModel: ServerConsoleViewModel
    @AppStorage("lynxnodes_console_font_size") private var consoleFontSize: Double = 12.0
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            
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
                                Text("Esperando salida de consola...")
                                    .font(.system(size: CGFloat(consoleFontSize), weight: .regular, design: .monospaced))
                                    .foregroundColor(LynxTheme.textMuted)
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
                    .background(Color(red: 0.03, green: 0.03, blue: 0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
                    )
                    .onChange(of: viewModel.logs.count) { _ in
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
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .foregroundColor(viewModel.autoScrollEnabled ? LynxTheme.goldBright : LynxTheme.textSecondary)
                    }
                    
                    // Botón Copiar Logs
                    Button {
                        viewModel.copyAllLogs()
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(7)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    // Botón Limpiar
                    Button {
                        viewModel.clearLogs()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.70))
                            .padding(7)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(10)
            }
            
            // Campo de Entrada de Comandos con Acento Dorado
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Text(">")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(LynxTheme.goldBright)
                    
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
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.50))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isInputFocused ? LynxTheme.gold.opacity(0.5) : Color.white.opacity(0.12), lineWidth: 0.8)
                )
                
                // Botón Enviar en Amarillo Dorado Lynx
                Button {
                    viewModel.sendCurrentCommand()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 38, height: 38)
                        .background(LynxTheme.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .shadow(color: LynxTheme.gold.opacity(0.35), radius: 6, y: 2)
                }
                .disabled(viewModel.commandInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Barra de Métricas en Vivo
    
    private func liveStatsBar() -> some View {
        GlassCard(cornerRadius: 16, padding: 12) {
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    metricItem(label: "CPU", value: viewModel.stats.formattedCpu, highlightColor: LynxTheme.goldBright)
                    metricItem(label: "RAM", value: "\(viewModel.stats.formattedMemoryUsed) / \(viewModel.stats.formattedMemoryLimit)", highlightColor: .white)
                    metricItem(label: "Disco", value: viewModel.stats.formattedDisk, highlightColor: .white)
                    metricItem(label: "Uptime", value: viewModel.stats.formattedUptime, highlightColor: LynxTheme.goldBright)
                }
                
                // Tráfico de red
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 9))
                            .foregroundColor(Color(red: 0.30, green: 0.85, blue: 0.45))
                        Text(viewModel.stats.formattedNetworkRx)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(white: 0.70))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 9))
                            .foregroundColor(LynxTheme.goldBright)
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
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(LynxTheme.textSecondary)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(highlightColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
