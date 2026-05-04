//
//  DocumentService.swift
//  MarkFlow Studio
//

import Foundation
import SwiftData

enum DocumentService {
    static func createDocument(folderId: UUID?, in context: ModelContext) throws -> MarkdownDocument {
        let document = MarkdownDocument(
            title: "Untitled Document",
            content: "# Untitled Document\n\nStart writing in Markdown.",
            folderId: folderId
        )
        context.insert(document)
        try context.save()
        return document
    }

    static func updateContent(_ document: MarkdownDocument, content: String, in context: ModelContext) throws {
        guard document.content != content else { return }
        document.updateContent(content)
        try context.save()
    }

    static func rename(_ document: MarkdownDocument, to title: String, in context: ModelContext) throws {
        let normalizedTitle = normalizedTitle(title)
        guard document.title != normalizedTitle else { return }
        document.rename(to: normalizedTitle)
        try context.save()
    }

    static func duplicate(_ document: MarkdownDocument, in context: ModelContext) throws -> MarkdownDocument {
        let copy = MarkdownDocument(
            title: "\(document.title) Copy",
            content: document.content,
            folderId: document.folderId
        )
        context.insert(copy)
        try context.save()
        return copy
    }

    static func softDelete(_ document: MarkdownDocument, in context: ModelContext) throws {
        document.softDelete()
        try context.save()
    }

    static func search(_ documents: [MarkdownDocument], query: String) -> [MarkdownDocument] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return documents }

        return documents.filter { document in
            document.title.localizedCaseInsensitiveContains(normalizedQuery)
                || document.content.localizedCaseInsensitiveContains(normalizedQuery)
        }
    }

    private static func normalizedTitle(_ title: String) -> String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTitle.isEmpty ? "Untitled Document" : trimmedTitle
    }
}
