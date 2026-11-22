import SwiftUI

/// Fila individual de archivo o carpeta con información y acciones rápidas
struct FileRowView: View {
    let file: FileItem
    let onOpen: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 12) {
                // Icono según tipo de archivo
                Image(systemName: file.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(file.isDirectory ? SmartTheme.blueBright : SmartTheme.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                // Nombre y detalles
                VStack(alignment: .leading, spacing: 3) {
                    Text(file.name)
                        .font(.system(size: 14, weight: .medium, design: file.isDirectory ? .default : .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        if !file.isDirectory {
                            Text(file.formattedSize)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Color(white: 0.50))
                        }
                        
                        Text(file.modeBits)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(white: 0.35))
                    }
                }
                
                Spacer()
                
                if file.isDirectory {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(white: 0.35))
                } else if file.isEditableText {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                        .foregroundColor(Color(white: 0.40))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            if file.isEditableText {
                Button {
                    onOpen()
                } label: {
                    Label("Editar Archivo", systemImage: "pencil")
                }
            }
            
            Button {
                onRename()
            } label: {
                Label("Renombrar", systemImage: "character.cursor.ibeam")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }
}
