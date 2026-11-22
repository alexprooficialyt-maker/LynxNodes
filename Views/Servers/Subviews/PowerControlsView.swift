import SwiftUI

/// Botones de control de energía con confirmaciones de seguridad
struct PowerControlsView: View {
    @ObservedObject var viewModel: ServerConsoleViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            // Encender (Start)
            powerButton(
                title: "Iniciar",
                iconType: .powerStart,
                tint: SmartTheme.statusRunning,
                disabled: viewModel.serverState == .running || viewModel.isPerformingPowerAction
            ) {
                Task {
                    await viewModel.performPowerAction(.start)
                }
            }
            
            // Reiniciar (Restart)
            powerButton(
                title: "Reiniciar",
                iconType: .powerRestart,
                tint: SmartTheme.statusStarting,
                disabled: viewModel.serverState == .offline || viewModel.isPerformingPowerAction
            ) {
                Task {
                    await viewModel.performPowerAction(.restart)
                }
            }
            
            // Apagar (Stop) con confirmación
            powerButton(
                title: "Apagar",
                iconType: .powerStop,
                tint: SmartTheme.statusStopping,
                disabled: viewModel.serverState == .offline || viewModel.isPerformingPowerAction
            ) {
                viewModel.showStopConfirmation = true
            }
            
            // Forzar Apagado (Kill) con confirmación
            powerButton(
                title: "Forzar",
                iconType: .powerKill,
                tint: SmartTheme.statusOffline,
                disabled: viewModel.serverState == .offline || viewModel.isPerformingPowerAction
            ) {
                viewModel.showKillConfirmation = true
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .liquidGlass(cornerRadius: 18, strokeOpacity: 0.12, fillOpacity: 0.45)
        .confirmationDialog(
            "¿Deseas apagar el servidor de forma segura?",
            isPresented: $viewModel.showStopConfirmation,
            titleVisibility: .visible
        ) {
            Button("Apagar Servidor", role: .destructive) {
                Task {
                    await viewModel.performPowerAction(.stop)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Se enviará la señal de apagado ordenado al servidor.")
        }
        .confirmationDialog(
            "¿Forzar apagado inmediato?",
            isPresented: $viewModel.showKillConfirmation,
            titleVisibility: .visible
        ) {
            Button("Forzar Apagado Inmediato", role: .destructive) {
                Task {
                    await viewModel.performPowerAction(.kill)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción terminará el proceso del servidor al instante sin guardar el estado actual.")
        }
    }
    
    private func powerButton(
        title: String,
        iconType: CustomIcon.IconType,
        tint: Color,
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                CustomIcon(type: iconType, size: 16, color: disabled ? Color(white: 0.40) : tint)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(disabled ? Color(white: 0.40) : Color.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(disabled ? Color.white.opacity(0.03) : tint.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(disabled ? Color.clear : tint.opacity(0.3), lineWidth: 0.8)
            )
        }
        .disabled(disabled)
        .buttonStyle(PlainButtonStyle())
    }
}
