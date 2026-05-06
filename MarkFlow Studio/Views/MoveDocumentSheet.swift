//
//  MoveDocumentSheet.swift
//  MarkFlow Studio
//

import SwiftUI

struct MoveDocumentSheet: View {
    @Environment(\.dismiss) private var dismiss

    let document: MarkdownDocument
    let folderTreeItems: [FolderTreeItem]
    let onMove: (UUID?) -> Void

    var body: some View {
        NavigationStack {
            List {
                Button {
                    move(to: nil)
                } label: {
                    Label("No Folder", systemImage: document.folderId == nil ? "checkmark.circle.fill" : "tray")
                }
                .accessibilityValue(document.folderId == nil ? "Current location" : "")
                .accessibilityAddTraits(document.folderId == nil ? .isSelected : [])

                ForEach(folderTreeItems) { item in
                    Button {
                        move(to: item.folder.id)
                    } label: {
                        HStack(spacing: 8) {
                            Text(String(repeating: "  ", count: item.depth))
                                .accessibilityHidden(true)
                            Image(systemName: document.folderId == item.folder.id ? "checkmark.circle.fill" : "folder")
                                .accessibilityHidden(true)
                            Text(item.folder.name)
                        }
                    }
                    .accessibilityLabel(item.folder.name)
                    .accessibilityValue(document.folderId == item.folder.id ? "Current location" : "")
                    .accessibilityAddTraits(document.folderId == item.folder.id ? .isSelected : [])
                }
            }
            .navigationTitle("Move Document")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func move(to folderId: UUID?) {
        onMove(folderId)
        dismiss()
    }
}
