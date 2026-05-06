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
    @State private var searchText = ""

    private var visibleFolderTreeItems: [FolderTreeItem] {
        let normalizedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedSearch.isEmpty else { return folderTreeItems }
        return folderTreeItems.filter { item in
            item.folder.name.localizedCaseInsensitiveContains(normalizedSearch)
        }
    }

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

                if visibleFolderTreeItems.isEmpty {
                    ContentUnavailableView(
                        "No Matching Folders",
                        systemImage: "folder.badge.questionmark",
                        description: Text("Try a different folder name or move the document to No Folder.")
                    )
                } else {
                    ForEach(visibleFolderTreeItems) { item in
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
            }
            .navigationTitle("Move Document")
            .searchable(text: $searchText, prompt: "Search folders")
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
