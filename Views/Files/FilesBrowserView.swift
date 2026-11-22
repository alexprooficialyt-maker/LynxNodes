import SwiftUI

/// Explorador de archivos y carpetas del servidor
struct FilesBrowserView: View {
    let serverId: String
    @StateObject private var viewModel: ServerFilesViewModel
    
    init(serverId: String) {
        self.serverId = serverId
        _viewModel = StateObject(wrappedValue: ServerFilesViewModel(serverId: serverId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Barra de Ruta (Breadcrumbs) y Botones de Acción
            HStack {
                BreadcrumbsView(currentPath: viewModel.currentPath) { selectedPath in
                    Task {
                        await viewModel.loadFiles(directory: selectedPath)
                    }
                }
                
                Spacer()
                
                // Botón Nueva Carpeta
                Button {
                    viewModel.newFolderName = ""
                    viewModel.showNewFolderAlert = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                .padding(.trailing, 16)
            }
            .padding(.top, 8)
            .padding(.bottom, 6)
            
            Divider()
                .background(Color.white.opacity(0.08))
            
            // Lista de Contenidos
            ScrollView {
                LazyVStack(spacing: 8) {
                    // Botón para subir al directorio superior si no estamos en raíz
                    if viewModel.currentPath != "/" {
                        Button {
                            Task {
                                await viewModel.navigateUp()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.turn.up.left")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.35, green: 0.65, blue: 1.0))
                                
                                Text(".. Directorio anterior")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(white: 0.70))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.03))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if viewModel.isLoading && viewModel.files.isEmpty {
                        SkeletonLoader()
                    } else if viewModel.files.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "folder")
                                .font(.system(size: 32))
                                .foregroundColor(Color(white: 0.35))
                            
                            Text("Carpeta vacía")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(white: 0.60))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        ForEach(viewModel.files) { file in
                            FileRowView(
                                file: file,
                                onOpen: {
                                    if file.isDirectory {
                                        Task {
                                            await viewModel.navigateToFolder(file.name)
                                        }
                                    } else if file.isEditableText {
                                        Task {
                                            await viewModel.openFileForEditing(file)
                                        }
                                    }
                                },
                                onRename: {
                                    viewModel.fileToRename = file
                                    viewModel.newFileName = file.name
                                    viewModel.showRenameAlert = true
                                },
                                onDelete: {
                                    viewModel.fileToDelete = file
                                    viewModel.showDeleteConfirmation = true
                                }
                            )
                        }
                    }
                    
                    // Margen inferior para que ningún archivo quede tapado por el menú flotante
                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            .refreshable {
                await viewModel.loadFiles()
            }
        }
        .task {
            await viewModel.loadFiles()
        }
        // Hoja del Editor de Archivos
        .sheet(isPresented: $viewModel.isFileEditorPresented) {
            if let file = viewModel.selectedFileForEdit {
                FileEditorView(
                    fileName: file.name,
                    content: $viewModel.fileEditorContent,
                    onSave: {
                        await viewModel.saveCurrentFile()
                    },
                    isSaving: viewModel.isSavingFile,
                    saveSuccess: viewModel.fileSaveSuccess
                )
            }
        }
        // Diálogo Nueva Carpeta
        .alert("Nueva Carpeta", isPresented: $viewModel.showNewFolderAlert) {
            TextField("Nombre de la carpeta", text: $viewModel.newFolderName)
                .autocapitalization(.none)
            Button("Crear") {
                Task {
                    await viewModel.createFolder()
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Introduce el nombre del nuevo directorio.")
        }
        // Diálogo Renombrar
        .alert("Renombrar", isPresented: $viewModel.showRenameAlert) {
            TextField("Nuevo nombre", text: $viewModel.newFileName)
                .autocapitalization(.none)
            Button("Guardar") {
                Task {
                    await viewModel.renameFile()
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Modifica el nombre del elemento.")
        }
        // Confirmación Eliminar
        .confirmationDialog(
            "¿Eliminar \(viewModel.fileToDelete?.name ?? "este archivo")?",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Eliminar definitivamente", role: .destructive) {
                Task {
                    await viewModel.deleteConfirmedFile()
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
    }
}
