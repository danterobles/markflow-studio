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
    @State private var path: [PhoneRoute] = []

    private var folderTreeItems: [FolderTreeItem] {
        FolderService.flattenedFolders(from: folders)
    }

    var body: some View {
        NavigationStack(path: $path) {
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
                        VStack(alignment: .leading, spacing: 12) {
                            ContentUnavailableView("No Folders", systemImage: "folder", description: Text("Create a folder to organize documents by topic, project, or client."))

                            Button {
                                folderActions.createFolder(nil)
                            } label: {
                                Label("Create First Folder", systemImage: "folder.badge.plus")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
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
                        folderId: folderId,
                        folderName: folderName(for: folderId),
                        selectedDocumentId: $selectedDocumentId,
                        path: $path,
                        actions: actions
                    )
                    .onAppear {
                        selectedFolderId = folderId
                    }
                case .document(let documentId):
                    DocumentDetailView(
                        document: documents.first { $0.id == documentId },
                        documents: documents,
                        links: links,
                        brokenLinkCount: brokenLinkCount(for: documentId),
                        actions: actions
                    )
                    .onAppear {
                        selectedDocumentId = documentId
                    }
                }
            }
        }
    }

    private func documents(for folderId: UUID?) -> [MarkdownDocument] {
        guard let folderId else { return documents }
        return documents.filter { $0.folderId == folderId }
    }

    private func folderName(for folderId: UUID?) -> String? {
        guard let folderId else { return nil }
        return folders.first { $0.id == folderId }?.name
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
    let folderId: UUID?
    let folderName: String?
    @Binding var selectedDocumentId: UUID?
    @Binding var path: [PhoneRoute]
    let actions: DocumentActionContext
    @State private var searchText = ""

    private var visibleDocuments: [MarkdownDocument] {
        DocumentService.search(documents, query: searchText)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if visibleDocuments.isEmpty {
                DocumentEmptyStateView(
                    searchText: searchText,
                    addDocument: addDocumentAndOpen
                )
            } else {
                List {
                    ForEach(visibleDocuments) { document in
                        NavigationLink(value: PhoneRoute.document(document.id)) {
                            DocumentCardView(
                                document: document,
                                isSelected: selectedDocumentId == document.id,
                                brokenLinkCount: brokenLinkCount(for: document),
                                backlinkCount: backlinkCount(for: document)
                            )
                        }
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
                addDocumentAndOpen()
            }
            .padding()
        }
        .background(AppBackgroundView())
        .navigationTitle(folderName ?? "All Documents")
        .safeAreaInset(edge: .top, spacing: 0) {
            CompactBreadcrumbView(folderName: folderName, documentCount: visibleDocuments.count)
        }
        .searchable(text: $searchText, prompt: "Search title or content")
        .tint(MarkFlowTheme.accent)
        .toolbar {
            ToolbarItem {
                Button {
                    addDocumentAndOpen()
                } label: {
                    Label("Add Document", systemImage: "plus")
                }
            }
        }
    }

    private func brokenLinkCount(for document: MarkdownDocument) -> Int {
        links.filter { $0.sourceDocumentId == document.id && $0.isBroken }.count
    }

    private func backlinkCount(for document: MarkdownDocument) -> Int {
        links.filter { $0.targetDocumentId == document.id && !$0.isBroken }.count
    }

    private func addDocumentAndOpen() {
        let previousDocumentId = selectedDocumentId
        actions.addDocument(folderId)

        guard let newDocumentId = selectedDocumentId, newDocumentId != previousDocumentId else { return }
        path.append(.document(newDocumentId))
    }
}

private struct CompactBreadcrumbView: View {
    let folderName: String?
    let documentCount: Int

    var body: some View {
        HStack(spacing: 8) {
            Label(folderName == nil ? "Workspace" : "Folder", systemImage: folderName == nil ? "tray.full" : "folder")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MarkFlowTheme.accent)

            Text(folderName ?? "All Documents")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Text("\(documentCount)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.12), in: Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.bar)
        .accessibilityElement(children: .combine)
    }
}
