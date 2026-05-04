//
//  MarkFlowPreviewData.swift
//  MarkFlow Studio
//

import Foundation
import SwiftData

enum MarkFlowPreviewData {
    @MainActor
    static var container: ModelContainer = {
        let schema = Schema([
            MarkdownDocument.self,
            MarkdownFolder.self,
            MarkdownLink.self,
            WorkspaceSettings.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            seed(container.mainContext)
            return container
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }()

    @MainActor
    private static func seed(_ context: ModelContext) {
        let folder = MarkdownFolder(name: "Notes")
        let childFolder = MarkdownFolder(name: "Architecture", parentId: folder.id)
        let document = MarkdownDocument(
            title: "Welcome to MarkFlow",
            content: "# Welcome\n\nUse [[Architecture]] to connect notes. [[Missing Note]] can become a document later.",
            folderId: folder.id
        )
        let targetDocument = MarkdownDocument(
            title: "Architecture",
            content: "# Architecture\n\nBacklink preview from [[Welcome to MarkFlow]].",
            folderId: childFolder.id
        )
        let link = MarkdownLink(
            sourceDocumentId: document.id,
            targetDocumentId: targetDocument.id,
            targetTitle: "Architecture"
        )
        let brokenLink = MarkdownLink(
            sourceDocumentId: document.id,
            targetTitle: "Missing Note"
        )
        let backlink = MarkdownLink(sourceDocumentId: targetDocument.id, targetDocumentId: document.id, targetTitle: document.title)
        let workspace = WorkspaceSettings(
            workspaceName: "Preview Workspace",
            storagePath: "/Preview/MarkFlow Studio Workspace"
        )

        context.insert(folder)
        context.insert(childFolder)
        context.insert(document)
        context.insert(targetDocument)
        context.insert(link)
        context.insert(brokenLink)
        context.insert(backlink)
        context.insert(workspace)
    }
}
