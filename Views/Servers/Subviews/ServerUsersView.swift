import SwiftUI

/// Vista de Subusuarios con acceso al servidor (GET /api/client/servers/{id}/users)
/// Estética Apple iOS 26 Liquid Glass en Negro, Azul y Blanco
struct ServerUsersView: View {
    let serverId: String
    
    @State private var subusers: [SubuserData] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var expandedUserId: String?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 14) {
                if isLoading && subusers.isEmpty {
                    VStack(spacing: 14) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: SmartTheme.blue))
                            .scaleEffect(1.1)
                        Text("Cargando usuarios con acceso...")
                            .font(.system(size: 13))
                            .foregroundColor(SmartTheme.textSecondary)
                    }
                    .padding(.top, 60)
                } else if let error = errorMessage, subusers.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(SmartTheme.statusOffline)
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(SmartTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        Button {
                            Task { await loadUsers() }
                        } label: {
                            Text("Reintentar")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(SmartTheme.blue)
                        }
                    }
                    .padding(.top, 50)
                } else if subusers.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.slash.fill")
                            .font(.system(size: 32))
                            .foregroundColor(SmartTheme.blue.opacity(0.4))
                        Text("Sin subusuarios adicionales")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Solo tú como propietario tienes acceso asignado a este servidor.")
                            .font(.system(size: 13))
                            .foregroundColor(SmartTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(subusers) { item in
                        userCard(item.attributes)
                    }
                }
                
                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
        .refreshable {
            await loadUsers()
        }
        .task {
            await loadUsers()
        }
    }
    
    @ViewBuilder
    private func userCard(_ user: SubuserAttributes) -> some View {
        let isExpanded = expandedUserId == user.uuid
        
        GlassCard(cornerRadius: 18, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    // Avatar / Icono
                    ZStack {
                        Circle()
                            .fill(SmartTheme.blue.opacity(0.18))
                            .frame(width: 42, height: 42)
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(SmartTheme.blueBright)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(user.username)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            
                            // Indicador 2FA
                            if user.twoFactorEnabled {
                                HStack(spacing: 3) {
                                    Circle()
                                        .fill(SmartTheme.statusRunning)
                                        .frame(width: 5, height: 5)
                                    Text("2FA")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(SmartTheme.statusRunning)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(SmartTheme.statusRunning.opacity(0.12))
                                .clipShape(Capsule())
                            } else {
                                Text("2FA OFF")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(SmartTheme.textMuted)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.white.opacity(0.06))
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Text(user.email)
                            .font(.system(size: 12))
                            .foregroundColor(SmartTheme.textSecondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.white.opacity(0.08))
                
                // Botón para desplegar permisos
                Button {
                    HapticFeedback.light()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        if isExpanded {
                            expandedUserId = nil
                        } else {
                            expandedUserId = user.uuid
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 12))
                            .foregroundColor(SmartTheme.blue)
                        
                        Text("\(user.permissions.count) permisos asignados")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(SmartTheme.textMuted)
                    }
                    .padding(.vertical, 4)
                }
                
                // Lista de permisos desplegada
                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        FlowLayout(spacing: 6) {
                            ForEach(user.readablePermissions, id: \.self) { perm in
                                Text(perm)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(SmartTheme.blueBright)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 4)
                                    .background(SmartTheme.blue.opacity(0.12))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(SmartTheme.blue.opacity(0.25), lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
    
    private func loadUsers() async {
        isLoading = true
        errorMessage = nil
        do {
            self.subusers = try await PterodactylAPI.shared.getServerSubusers(id: serverId)
        } catch {
            self.errorMessage = "No se pudo obtener la lista de usuarios con acceso."
        }
        isLoading = false
    }
}

/// Helper para colocar tags/píldoras en varias filas
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeightInRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width && currentX > 0 {
                currentX = 0
                currentY += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            currentX += size.width + spacing
            maxHeightInRow = max(maxHeightInRow, size.height)
        }
        return CGSize(width: width, height: currentY + maxHeightInRow)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var maxHeightInRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            maxHeightInRow = max(maxHeightInRow, size.height)
        }
    }
}
