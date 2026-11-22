import SwiftUI

/// Pestaña Servidores: Lista completa con buscador, filtros y 100% Datos Reales
struct ServerListView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    @StateObject private var viewModel = ServerListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Buscador y Filtros
                VStack(spacing: 12) {
                    // Barra de Búsqueda
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.0))
                        
                        TextField("Buscar por nombre, nodo o ID...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !viewModel.searchText.isEmpty {
                            Button {
                                viewModel.searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(white: 0.45))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(red: 0.07, green: 0.08, blue: 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(viewModel.searchText.isEmpty ? Color.white.opacity(0.12) : Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.5), lineWidth: 0.8)
                    )
                    
                    // Píldoras de Filtro
                    HStack(spacing: 8) {
                        ForEach(ServerListViewModel.ServerFilter.allCases) { filter in
                            let isSelected = viewModel.selectedFilter == filter
                            Button {
                                HapticFeedback.light()
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.selectedFilter = filter
                                }
                            } label: {
                                Text(filter.rawValue)
                                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(isSelected ? Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.20) : Color.white.opacity(0.04))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(isSelected ? Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.6) : Color.white.opacity(0.08), lineWidth: 0.8)
                                    )
                                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.76, blue: 0.1) : Color(white: 0.70))
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 14)
                
                // Lista de Servidores
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        if viewModel.isLoading && viewModel.servers.isEmpty {
                            SkeletonLoader()
                        } else if viewModel.filteredServers.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "server.rack")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.0).opacity(0.4))
                                
                                Text("No se encontraron servidores")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Comprueba tus filtros o verifica que tu cuenta tenga servidores asignados.")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(white: 0.55))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(viewModel.filteredServers) { server in
                                NavigationLink {
                                    ServerDetailView(server: server)
                                } label: {
                                    ServerCardView(server: server)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // ESPACIO INFERIOR AMPLIADO: Garantiza que la última tarjeta nunca quede tapada
                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.loadServers(appEnv: appEnv, forceRefresh: true)
                }
            }
            .navigationTitle("Servidores")
            .navigationBarTitleDisplayMode(.inline)
            .liquidDarkBackground()
            .task {
                await viewModel.loadServers(appEnv: appEnv)
                viewModel.startAutoRefresh(appEnv: appEnv)
            }
            .onDisappear {
                viewModel.stopAutoRefresh()
            }
        }
    }
}
