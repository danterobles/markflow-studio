//
//  PhoneAppShellView.swift
//  MarkFlow Studio
//

import SwiftUI

struct PhoneAppShellView: View {
    let folders: [MarkdownFolder]
    let documents: [MarkdownDocument]
    let links: [MarkdownLink]
    let workspace: WorkspaceSettings?
    let workspaceErrorMessage: String?
    @Binding var selectedFolderId: UUID?
    @Binding var selectedDocumentId: UUID?
    let actions: DocumentActionContext
    let folderActions: FolderActionContext

    private var folderTreeItems: [FolderTreeItem] {
        FolderService.flattenedFolders(from: folders)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    WorkspaceStatusCard(
                        workspace: workspace,
                        errorMessage: workspaceErrorMessage,
                        selectWorkspace: actions.selectWorkspace
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                Section("Library") {
                    NavigationLink(value: PhoneRoute.documents(nil)) {
                        Label("All Documents", systemImage: "tray.full")
                    }
                }

                Section("Folders") {
                    if folders.isEmpty {
                        ContentUnavailableView("No Folders", systemImage: "folder", description: Text("Create a folder to organize documents."))
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(folderTreeItems) { item in
                            NavigationLink(value: PhoneRoute.documents(item.folder.id)) {
                                HStack(spacing: 8) {
                                    Color.clear
                                        .frame(width: CGFloat(item.depth) * 14)
                                        .accessibilityHidden(true)
                                    Label(item.folder.name, systemImage: "folder")
                                }
                            }
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
            .scrollContentBackground(.hidden)
            .background(AppBackgroundView())
            .tint(MarkFlowTheme.accent)
            .toolbar {
                ToolbarItem {
                    Button {
                        folderActions.createFolder(selectedFolderId)
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                }
            }
            .navigationDestination(for: PhoneRoute.self) { route in
                switch route {
                case .documents(let folderId):
                    DocumentStackView(
                        documents: documents(for: folderId),
                        links: links,
                        selectedDocumentId: $selectedDocumentId,
                        actions: actions
                    )
                    .onAppear {
                        selectedFolderId = folderId
                    }
                case .document(let documentId):
                    let visibleDocumentId = selectedDocumentId ?? documentId
                    DocumentDetailView(
                        document: documents.first { $0.id == visibleDocumentId },
                        documents: documents,
                        links: links,
                        brokenLinkCount: brokenLinkCount(for: visibleDocumentId),
                        actions: actions
                    )
                }
            }
        }
    }

    private func documents(for folderId: UUID?) -> [MarkdownDocument] {
        guard let folderId else { return documents }
        return documents.filter { $0.folderId == folderId }
    }

    private func brokenLinkCount(for documentId: UUID) -> Int {
        links.filter { $0.sourceDocumentId == documentId && $0.isBroken }.count
    }
}

private enum PhoneRoute: Hashable {
    case documents(UUID?)
    case document(UUID)
}

private struct DocumentStackView: View {
    let documents: [MarkdownDocument]
    let links: [MarkdownLink]
    @Binding var selectedDocumentId: UUID?
    let actions: DocumentActionContext
    @State private var searchText = ""

    private var visibleDocuments: [MarkdownDocument] {
        DocumentService.search(documents, query: searchText)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if visibleDocuments.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "No Documents" : "No Results",
                    systemImage: searchText.isEmpty ? "doc.text" : "magnifyingglass",
                    description: Text(searchText.isEmpty ? "Create a document to start writing Markdown." : "Try a different title or content search.")
                )
                .padding(28)
                .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
                .padding(24)
            } else {
                List {
                    ForEach(visibleDocuments) { document in
                        NavigationLink(value: PhoneRoute.document(document.id)) {
                            DocumentCardView(
                                document: document,
                                isSelected: selectedDocumentId == document.id,
                                brokenLinkCount: brokenLinkCount(for: document)
                            )
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            selectedDocumentId = document.id
                        })
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                actions.deleteDocument(document)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                actions.moveDocument(document)
                            } label: {
                                Label("Move", systemImage: "folder")
                            }
                            .tint(.blue)
                        }
                        .contextMenu {
                            Button {
                                actions.duplicateDocument(document)
                            } label: {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }

                            Button {
                                actions.moveDocument(document)
                            } label: {
                                Label("Move to Folder", systemImage: "folder")
                            }

                            Button(role: .destructive) {
                                actions.deleteDocument(document)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .contentMargins(.vertical, 12, for: .scrollContent)
                .contentMargins(.horizontal, 10, for: .scrollContent)
            }

            FloatingToolbarView {
                actions.addDocument(nil)
            }
            .padding()
        }
        .background(AppBackgroundView())
        .navigationTitle("Documents")
        .searchable(text: $searchText, prompt: "Search title or content")
        .tint(MarkFlowTheme.accent)
        .toolbar {
            ToolbarItem {
                Button {
                    actions.addDocument(nil)
                } label: {
                    Label("Add Document", systemImage: "plus")
                }
            }
        }
    }

    private func brokenLinkCount(for document: MarkdownDocument) -> Int {
        links.filter { $0.sourceDocumentId == document.id && $0.isBroken }.count
    }
}
