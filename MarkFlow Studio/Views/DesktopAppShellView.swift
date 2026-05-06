//
//  DesktopAppShellView.swift
//  MarkFlow Studio
//

import SwiftUI

struct DesktopAppShellView: View {
    let folders: [MarkdownFolder]
    let documents: [MarkdownDocument]
    let allDocuments: [MarkdownDocument]
    let links: [MarkdownLink]
    let workspace: WorkspaceSettings?
    let workspaceErrorMessage: String?
    @Binding var selectedFolderId: UUID?
    @Binding var selectedDocumentId: UUID?
    let actions: DocumentActionContext
    let folderActions: FolderActionContext

    var body: some View {
        NavigationSplitView {
            FolderSidebarView(
                folders: folders,
                workspace: workspace,
                errorMessage: workspaceErrorMessage,
                selectedFolderId: $selectedFolderId,
                selectWorkspace: actions.selectWorkspace,
                folderActions: folderActions
            )
            .navigationSplitViewColumnWidth(min: 240, ideal: 280)
        } content: {
            DocumentListView(
                documents: documents,
                links: links,
                contextTitle: selectedFolderName ?? "All Documents",
                contextSubtitle: selectedFolderName == nil ? "Workspace library" : "Folder",
                selectedDocumentId: $selectedDocumentId,
                actions: actions
            )
            .navigationSplitViewColumnWidth(min: 320, ideal: 380)
        } detail: {
            DocumentDetailView(
                document: selectedDocument,
                documents: allDocuments,
                links: links,
                brokenLinkCount: selectedDocument.map { brokenLinkCount(for: $0) } ?? 0,
                actions: actions
            )
        }
    }

    private var selectedDocument: MarkdownDocument? {
        documents.first { $0.id == selectedDocumentId }
    }

    private var selectedFolderName: String? {
        guard let selectedFolderId else { return nil }
        return folders.first { $0.id == selectedFolderId }?.name
    }

    private func brokenLinkCount(for document: MarkdownDocument) -> Int {
        links.filter { $0.sourceDocumentId == document.id && $0.isBroken }.count
    }
}
