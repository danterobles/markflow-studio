//
//  WikiLinkService.swift
//  MarkFlow Studio
//

import Foundation
import SwiftData

enum WikiLinkService {
    static func syncLinks(
        for document: MarkdownDocument,
        documents: [MarkdownDocument],
        links: [MarkdownLink],
        in context: ModelContext
    ) throws {
        links
            .filter { $0.sourceDocumentId == document.id }
            .forEach { context.delete($0) }

        let activeDocuments = documents.filter { !$0.isDeleted }
        let targetTitles = parseTargetTitles(in: document.content)

        for title in targetTitles {
            let target = activeDocuments.first { $0.title.localizedCaseInsensitiveCompare(title) == .orderedSame }
            context.insert(MarkdownLink(
                sourceDocumentId: document.id,
                targetDocumentId: target?.id,
                targetTitle: target?.title ?? title,
                isBroken: target == nil
            ))
        }

        try context.save()
    }

    static func syncAllLinks(documents: [MarkdownDocument], links: [MarkdownLink], in context: ModelContext) throws {
        for link in links {
            context.delete(link)
        }

        let activeDocuments = documents.filter { !$0.isDeleted }
        for document in activeDocuments {
            for title in parseTargetTitles(in: document.content) {
                let target = activeDocuments.first { $0.title.localizedCaseInsensitiveCompare(title) == .orderedSame }
                context.insert(MarkdownLink(
                    sourceDocumentId: document.id,
                    targetDocumentId: target?.id,
                    targetTitle: target?.title ?? title,
                    isBroken: target == nil
                ))
            }
        }

        try context.save()
    }

    static func backlinks(to document: MarkdownDocument, documents: [MarkdownDocument], links: [MarkdownLink]) -> [MarkdownDocument] {
        let sourceIds = Set(links.compactMap { link -> UUID? in
            link.targetDocumentId == document.id ? link.sourceDocumentId : nil
        })
        return documents
            .filter { sourceIds.contains($0.id) && !$0.isDeleted }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    static func outgoingLinks(from document: MarkdownDocument, links: [MarkdownLink]) -> [MarkdownLink] {
        links
            .filter { $0.sourceDocumentId == document.id }
            .sorted { $0.targetTitle.localizedCaseInsensitiveCompare($1.targetTitle) == .orderedAscending }
    }

    static func createDocument(fromBrokenLink link: MarkdownLink, sourceDocument: MarkdownDocument, in context: ModelContext) throws -> MarkdownDocument {
        let document = MarkdownDocument(
            title: normalizedTitle(link.targetTitle),
            content: "# \(normalizedTitle(link.targetTitle))\n\nCreated from [[\(sourceDocument.title)]].",
            folderId: sourceDocument.folderId
        )
        context.insert(document)
        try context.save()
        return document
    }

    static func updateReferences(from oldTitle: String, to newTitle: String, in documents: [MarkdownDocument], context: ModelContext) throws {
        guard oldTitle.localizedCaseInsensitiveCompare(newTitle) != .orderedSame else { return }

        for document in documents where !document.isDeleted {
            let updatedContent = replacingWikiLinks(in: document.content, oldTitle: oldTitle, newTitle: newTitle)
            if updatedContent != document.content {
                document.updateContent(updatedContent)
            }
        }

        try context.save()
    }

    private static func parseTargetTitles(in content: String) -> [String] {
        var titles: [String] = []
        var searchStart = content.startIndex

        while let openingRange = content[searchStart...].range(of: "[["),
              let closingRange = content[openingRange.upperBound...].range(of: "]]") {
            let title = content[openingRange.upperBound..<closingRange.lowerBound]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !title.isEmpty {
                titles.append(title)
            }
            searchStart = closingRange.upperBound
        }

        return titles
    }

    private static func replacingWikiLinks(in content: String, oldTitle: String, newTitle: String) -> String {
        var result = ""
        var searchStart = content.startIndex

        while let openingRange = content[searchStart...].range(of: "[["),
              let closingRange = content[openingRange.upperBound...].range(of: "]]") {
            result += content[searchStart..<openingRange.lowerBound]

            let title = content[openingRange.upperBound..<closingRange.lowerBound]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if title.localizedCaseInsensitiveCompare(oldTitle) == .orderedSame {
                result += "[[\(newTitle)]]"
            } else {
                result += content[openingRange.lowerBound..<closingRange.upperBound]
            }

            searchStart = closingRange.upperBound
        }

        result += content[searchStart..<content.endIndex]
        return result
    }

    private static func normalizedTitle(_ title: String) -> String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTitle.isEmpty ? "Untitled Document" : trimmedTitle
    }
}
