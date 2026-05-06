//
//  ContentView.swift
//  MarkFlow Studio
//
//  Created by Dante Robles on 04/05/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Query(filter: #Predicate<MarkdownDocument> { document in
        !document.isSoftDeleted
    }, sort: \MarkdownDocument.updatedAt, order: .reverse) private var documents: [MarkdownDocument]
    @Query(sort: \MarkdownFolder.name) private var folders: [MarkdownFolder]
    @Query private var links: [MarkdownLink]
    @Query private var workspaceSettings: [WorkspaceSettings]

    @State private var selectedFolderId: UUID?
    @State private var selectedDocumentId: UUID?
    @State private var isWorkspaceImporterPresented = false
    @State private var workspaceErrorMessage: String?
    @State private var feedback: AppFeedback?
    @State private var folderSheet: FolderSheet?
    @State private var documentToMove: MarkdownDocument?
    @State private var exportRequest: ExportRequest?
    @State private var didSyncWikiLinks = false

    var body: some View {
        ZStack(alignment: .top) {
            appShell

            if let feedback {
                FeedbackBannerView(feedback: feedback)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.smooth, value: feedback)
        .fileImporter(
            isPresented: $isWorkspaceImporterPresented,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false,
            onCompletion: handleWorkspaceSelection
        )
        .sheet(item: $folderSheet) { sheet in
            switch sheet {
            case .create(let parentId):
                FolderEditorSheet(title: "New Folder", saveTitle: "Create") { name in
                    createFolder(named: name, parentId: parentId)
                }
            case .rename(let folder):
                FolderEditorSheet(title: "Rename Folder", initialName: folder.name, saveTitle: "Rename") { name in
                    renameFolder(folder, to: name)
                }
            }
        }
        .sheet(item: $documentToMove) { document in
            MoveDocumentSheet(
                document: document,
                folderTreeItems: FolderService.flattenedFolders(from: folders)
            ) { folderId in
                moveDocument(document, to: folderId)
            }
        }
        .sheet(item: $exportRequest) { request in
            ExportPreflightSheet(
                request: request,
                documents: documents,
                folders: folders,
                links: links,
                workspace: activeWorkspace,
                selectWorkspace: selectWorkspace
            ) { confirmedRequest in
                performExport(confirmedRequest)
            }
        }
        .onAppear(perform: syncWikiLinksIfNeeded)
    }

    @ViewBuilder
    private var appShell: some View {
        if activeWorkspace == nil {
            WorkspaceOnboardingView(
                errorMessage: workspaceErrorMessage,
                selectWorkspace: selectWorkspace
            )
        } else {
#if os(macOS)
            desktopShell
#else
            if horizontalSizeClass == .compact {
                phoneShell
            } else {
                desktopShell
            }
#endif
        }
    }

    private var desktopShell: some View {
        DesktopAppShellView(
            folders: folders,
            documents: filteredDocuments,
            allDocuments: documents,
            links: links,
            workspace: activeWorkspace,
            workspaceErrorMessage: workspaceErrorMessage,
            selectedFolderId: $selectedFolderId,
            selectedDocumentId: $selectedDocumentId,
            actions: actions,
            folderActions: folderActions
        )
    }

    private var phoneShell: some View {
        PhoneAppShellView(
            folders: folders,
            documents: documents,
            links: links,
            workspace: activeWorkspace,
            workspaceErrorMessage: workspaceErrorMessage,
            selectedFolderId: $selectedFolderId,
            selectedDocumentId: $selectedDocumentId,
            actions: actions,
            folderActions: folderActions
        )
    }

    private var activeWorkspace: WorkspaceSettings? {
        workspaceSettings.first
    }

    private var filteredDocuments: [MarkdownDocument] {
        guard let selectedFolderId else { return documents }
        return documents.filter { $0.folderId == selectedFolderId }
    }

    private var actions: DocumentActionContext {
        DocumentActionContext(
            addDocument: addDocument,
            renameDocument: renameDocument,
            updateDocumentContent: updateDocumentContent,
            duplicateDocument: duplicateDocument,
            deleteDocument: deleteDocument,
            moveDocument: presentMoveDocument,
            exportDocument: exportDocument,
            navigateToDocument: navigateToDocument,
            createDocumentFromBrokenLink: createDocumentFromBrokenLink,
            selectWorkspace: selectWorkspace
        )
    }

    private var folderActions: FolderActionContext {
        FolderActionContext(
            createFolder: presentCreateFolder,
            renameFolder: presentRenameFolder,
            exportFolder: exportFolder
        )
    }

    private func selectWorkspace() {
        workspaceErrorMessage = nil
        isWorkspaceImporterPresented = true
    }

    private func handleWorkspaceSelection(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            try WorkspaceService.configureWorkspace(at: url, in: modelContext)
            workspaceErrorMessage = nil
            showFeedback(.workspaceReady)
        } catch {
            workspaceErrorMessage = AppFeedbackMessage.workspaceSetupFailureDetails(for: error)
            showFeedback(.workspaceSetupNeedsAttention)
        }
    }

    private func addDocument(folderId: UUID?) {
        do {
            let newDocument = try DocumentService.createDocument(folderId: folderId ?? selectedFolderId, in: modelContext)
            try WikiLinkService.syncLinks(for: newDocument, documents: documents + [newDocument], links: links, in: modelContext)
            withAnimation {
                selectedFolderId = newDocument.folderId
                selectedDocumentId = newDocument.id
            }
            showFeedback(.documentCreated)
        } catch {
            showFeedback(.documentCreationFailed)
        }
    }

    private func renameDocument(_ document: MarkdownDocument, to title: String) {
        do {
            let oldTitle = document.title
            try DocumentService.rename(document, to: title, in: modelContext)
            try WikiLinkService.updateReferences(from: oldTitle, to: document.title, in: documents, context: modelContext)
            try WikiLinkService.syncAllLinks(documents: documents, links: links, in: modelContext)
            showFeedback(.documentRenamed)
        } catch {
            showFeedback(.documentRenameFailed)
        }
    }

    private func updateDocumentContent(_ document: MarkdownDocument, to content: String) {
        do {
            try DocumentService.updateContent(document, content: content, in: modelContext)
            try WikiLinkService.syncLinks(for: document, documents: documents, links: links, in: modelContext)
        } catch {
            showFeedback(.documentSaveFailed)
        }
    }

    private func duplicateDocument(_ document: MarkdownDocument) {
        do {
            let newDocument = try DocumentService.duplicate(document, in: modelContext)
            try WikiLinkService.syncLinks(for: newDocument, documents: documents + [newDocument], links: links, in: modelContext)
            withAnimation {
                selectedFolderId = newDocument.folderId
                selectedDocumentId = newDocument.id
            }
            showFeedback(.documentDuplicated)
        } catch {
            showFeedback(.documentDuplicateFailed)
        }
    }

    private func deleteDocument(_ document: MarkdownDocument) {
        do {
            try DocumentService.softDelete(document, in: modelContext)
            try WikiLinkService.syncAllLinks(documents: documents, links: links, in: modelContext)
            withAnimation {
                if selectedDocumentId == document.id {
                    selectedDocumentId = filteredDocuments.first { $0.id != document.id }?.id
                }
            }
            showFeedback(.documentMovedToTrash)
        } catch {
            showFeedback(.documentDeleteFailed)
        }
    }

    private func presentCreateFolder(parentId: UUID?) {
        folderSheet = .create(parentId: parentId)
    }

    private func presentRenameFolder(_ folder: MarkdownFolder) {
        folderSheet = .rename(folder)
    }

    private func createFolder(named name: String, parentId: UUID?) {
        do {
            let folder = try FolderService.createFolder(named: name, parentId: parentId, in: modelContext)
            selectedFolderId = folder.id
            showFeedback(.folderCreated)
        } catch {
            showFeedback(.folderCreationFailed)
        }
    }

    private func renameFolder(_ folder: MarkdownFolder, to name: String) {
        do {
            try FolderService.rename(folder, to: name, in: modelContext)
            showFeedback(.folderRenamed)
        } catch {
            showFeedback(.folderRenameFailed)
        }
    }

    private func presentMoveDocument(_ document: MarkdownDocument) {
        documentToMove = document
    }

    private func moveDocument(_ document: MarkdownDocument, to folderId: UUID?) {
        do {
            try FolderService.moveDocument(document, to: folderId, in: modelContext)
            selectedFolderId = folderId
            selectedDocumentId = document.id
            showFeedback(.documentMoved)
        } catch {
            showFeedback(.documentMoveFailed)
        }
    }

    private func exportDocument(_ document: MarkdownDocument, format: ExportFormat) {
        exportRequest = .document(document, format)
    }

    private func exportFolder(_ folder: MarkdownFolder) {
        exportRequest = .folder(folder)
    }

    private func performExport(_ request: ExportRequest) {
        do {
            guard let activeWorkspace else { throw ExportError.missingWorkspace }
            switch request {
            case .document(let document, let format):
                let url = try ExportService.exportDocument(document, format: format, documents: documents, workspace: activeWorkspace)
                showFeedback(.documentExported(format: format, fileName: url.lastPathComponent))
            case .folder(let folder):
                let url = try ExportService.exportFolder(folder, documents: documents, folders: folders, workspace: activeWorkspace)
                showFeedback(.folderExported(fileName: url.lastPathComponent))
            }
        } catch {
            showFeedback(.exportFailed, error: error)
        }
    }

    private func navigateToDocument(_ documentId: UUID) {
        guard let document = documents.first(where: { $0.id == documentId }) else {
            showFeedback(.linkedDocumentMissing)
            return
        }
        selectedFolderId = document.folderId
        selectedDocumentId = document.id
        showFeedback(.linkedDocumentOpened)
    }

    private func createDocumentFromBrokenLink(_ link: MarkdownLink, sourceDocument: MarkdownDocument) {
        do {
            let document = try WikiLinkService.createDocument(fromBrokenLink: link, sourceDocument: sourceDocument, in: modelContext)
            try WikiLinkService.syncAllLinks(documents: documents + [document], links: links, in: modelContext)
            selectedFolderId = document.folderId
            selectedDocumentId = document.id
            showFeedback(.linkedDocumentCreated)
        } catch {
            showFeedback(.linkedDocumentCreationFailed)
        }
    }

    private func syncWikiLinksIfNeeded() {
        guard !didSyncWikiLinks else { return }
        didSyncWikiLinks = true

        do {
            try WikiLinkService.syncAllLinks(documents: documents, links: links, in: modelContext)
        } catch {
            showFeedback(.linkSyncFailed)
        }
    }

    private func showFeedback(_ message: AppFeedbackMessage, error: Error? = nil) {
        let text = message.text(error: error)
        feedback = AppFeedback(message: text, kind: message.kind)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            if feedback?.message == text {
                feedback = nil
            }
        }
    }
}

private enum FolderSheet: Identifiable {
    case create(parentId: UUID?)
    case rename(MarkdownFolder)

    var id: String {
        switch self {
        case .create(let parentId):
            "create-\(parentId?.uuidString ?? "root")"
        case .rename(let folder):
            "rename-\(folder.id.uuidString)"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(MarkFlowPreviewData.container)
}
