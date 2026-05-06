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
            Section("Library") {
                SidebarLibraryRow(title: "All Documents", systemImage: "tray.full", isSelected: selectedFolderId == nil)
                    .tag(nil as UUID?)
            }

            Section("Folders") {
                if folders.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ContentUnavailableView("No Folders", systemImage: "folder", description: Text("Create a folder to organize documents by topic, project, or client."))

                        Button {
                            folderActions.createFolder(nil)
                        } label: {
                            Label("Create First Folder", systemImage: "folder.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            WorkspaceStatusCard(
                workspace: workspace,
                errorMessage: errorMessage,
                selectWorkspace: selectWorkspace,
                isCompact: true
            )
            .padding(12)
            .background(.bar)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    folderActions.createFolder(selectedFolderId)
                } label: {
                    Label("New Folder", systemImage: "folder.badge.plus")
                }
                .tint(MarkFlowTheme.accent)
            }
        }
    }
}

private struct SidebarLibraryRow: View {
    let title: String
    let systemImage: String
    let isSelected: Bool

    var body: some View {
        Label(title, systemImage: systemImage)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(isSelected ? MarkFlowTheme.accent : .primary)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
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
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isSelected ? MarkFlowTheme.accent : .primary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
