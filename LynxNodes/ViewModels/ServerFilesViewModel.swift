import SwiftUI
import Combine

/// ViewModel para el explorador y editor de archivos
@MainActor
final class ServerFilesViewModel: ObservableObject {
    let serverId: String
    
    @Published var currentPath: String = "/"
    @Published var files: [FileItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Editor de archivo activo
    @Published var selectedFileForEdit: FileItem?
    @Published var fileEditorContent: String = ""
    @Published var isSavingFile: Bool = false
    @Published var isFileEditorPresented: Bool = false
    @Published var fileSaveSuccess: Bool = false
    
    // Diálogos de acción
    @Published var showNewFolderAlert: Bool = false
    @Published var newFolderName: String = ""
    
    @Published var fileToRename: FileItem?
    @Published var newFileName: String = ""
    @Published var showRenameAlert: Bool = false
    
    @Published var fileToDelete: FileItem?
    @Published var showDeleteConfirmation: Bool = false
    
    init(serverId: String) {
        self.serverId = serverId
    }
    
    // MARK: - Listar Archivos
    
    func loadFiles(directory: String? = nil) async {
        if let dir = directory {
            currentPath = dir
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched = try await PterodactylAPI.shared.listFiles(id: serverId, directory: currentPath)
            self.files = fetched
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            HapticFeedback.error()
        } catch {
            self.errorMessage = "Error al listar los archivos del directorio."
            HapticFeedback.error()
        }
        
        isLoading = false
    }
    
    func navigateToFolder(_ folderName: String) async {
        let newPath: String
        if currentPath == "/" {
            newPath = "/" + folderName
        } else {
            newPath = currentPath + "/" + folderName
        }
        await loadFiles(directory: newPath)
    }
    
    func navigateUp() async {
        guard currentPath != "/" else { return }
        var components = currentPath.split(separator: "/").map { String($0) }
        components.removeLast()
        let parentPath = components.isEmpty ? "/" : "/" + components.joined(separator: "/")
        await loadFiles(directory: parentPath)
    }
    
    // MARK: - Leer y Guardar Archivo
    
    func openFileForEditing(_ file: FileItem) async {
        guard file.isEditableText else { return }
        
        selectedFileForEdit = file
        isLoading = true
        errorMessage = nil
        
        let fullFilePath = (currentPath == "/" ? "/" : currentPath + "/") + file.name
        
        do {
            let content = try await PterodactylAPI.shared.getFileContents(id: serverId, filePath: fullFilePath)
            self.fileEditorContent = content
            self.isFileEditorPresented = true
            HapticFeedback.light()
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            HapticFeedback.error()
        } catch {
            self.errorMessage = "No se pudo descargar el contenido del archivo."
            HapticFeedback.error()
        }
        
        isLoading = false
    }
    
    func saveCurrentFile() async {
        guard let file = selectedFileForEdit else { return }
        
        isSavingFile = true
        fileSaveSuccess = false
        let fullFilePath = (currentPath == "/" ? "/" : currentPath + "/") + file.name
        
        do {
            try await PterodactylAPI.shared.writeFileContents(id: serverId, filePath: fullFilePath, content: fileEditorContent)
            self.fileSaveSuccess = true
            HapticFeedback.success()
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            HapticFeedback.error()
        } catch {
            self.errorMessage = "Error al guardar los cambios en el archivo."
            HapticFeedback.error()
        }
        
        isSavingFile = false
    }
    
    // MARK: - Crear Carpeta
    
    func createFolder() async {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        isLoading = true
        do {
            try await PterodactylAPI.shared.createFolder(id: serverId, root: currentPath, folderName: trimmed)
            newFolderName = ""
            HapticFeedback.success()
            await loadFiles(directory: currentPath)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            HapticFeedback.error()
        } catch {
            self.errorMessage = "No se pudo crear la carpeta."
            HapticFeedback.error()
        }
        isLoading = false
    }
    
    // MARK: - Renombrar
    
    func renameFile() async {
        guard let target = fileToRename else { return }
        let trimmed = newFileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty && trimmed != target.name else { return }
        
        isLoading = true
        do {
            try await PterodactylAPI.shared.renameFile(id: serverId, root: currentPath, from: target.name, to: trimmed)
            newFileName = ""
            fileToRename = nil
            HapticFeedback.success()
            await loadFiles(directory: currentPath)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            HapticFeedback.error()
        } catch {
            self.errorMessage = "Error al renombrar el archivo."
            HapticFeedback.error()
        }
        isLoading = false
    }
    
    // MARK: - Eliminar
    
    func deleteConfirmedFile() async {
        guard let target = fileToDelete else { return }
        
        isLoading = true
        do {
            try await PterodactylAPI.shared.deleteFiles(id: serverId, root: currentPath, fileNames: [target.name])
            fileToDelete = nil
            HapticFeedback.medium()
            await loadFiles(directory: currentPath)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            HapticFeedback.error()
        } catch {
            self.errorMessage = "Error al eliminar el archivo seleccionado."
            HapticFeedback.error()
        }
        isLoading = false
    }
}
