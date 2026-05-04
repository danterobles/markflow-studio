//
//  FolderSidebarView.swift
//  MarkFlow Studio
//

import SwiftUI

struct FolderSidebarView: View {
    let folders: [MarkdownFolder]
    let workspace: WorkspaceSettings?
    let errorMessage: String?
    @Binding var selectedFolderId: UUID?
    let selectWorkspace: () -> Void
    let folderActions: FolderActionContext

    private var folderTreeItems: [FolderTreeItem] {
        FolderService.flattenedFolders(from: folders)
    }

    var body: some View {
        List(selection: $selectedFolderId) {
            Section {
                WorkspaceStatusCard(
                    workspace: workspace,
                    errorMessage: errorMessage,
                    selectWorkspace: selectWorkspace
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section("Library") {
                Label("All Documents", systemImage: "tray.full")
                    .tag(nil as UUID?)
                    .accessibilityAddTraits(selectedFolderId == nil ? .isSelected : [])
            }

            Section("Folders") {
                if folders.isEmpty {
                    ContentUnavailableView("No Folders", systemImage: "folder", description: Text("Create a folder to organize documents."))
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(folderTreeItems) { item in
                        FolderRowView(item: item, isSelected: selectedFolderId == item.folder.id)
                            .tag(Optional(item.folder.id))
                            .contextMenu {
                                Button {
                                    folderActions.createFolder(item.folder.id)
                                } label: {
                                    Label("New Subfolder", systemImage: "folder.badge.plus")
                                }

                                Button {
                                    folderActions.renameFolder(item.folder)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }

                                Button {
                                    folderActions.exportFolder(item.folder)
                                } label: {
                                    Label("Export Folder", systemImage: "square.and.arrow.up")
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle("MarkFlow")
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(.thinMaterial)
        .toolbar {
            ToolbarItem {
                Button {
                    folderActions.createFolder(selectedFolderId)
                } label: {
                    Label("New Folder", systemImage: "folder.badge.plus")
                }
            }
        }
    }
}

private struct FolderRowView: View {
    let item: FolderTreeItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Color.clear
                .frame(width: CGFloat(item.depth) * 14)
                .accessibilityHidden(true)
            Label(item.folder.name, systemImage: "folder")
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
