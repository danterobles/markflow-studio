//
//  DocumentOrganizationOptions.swift
//  MarkFlow Studio
//

import Foundation

enum DocumentSortOption: String, CaseIterable, Identifiable {
    case modified
    case title
    case wordCount

    var id: String { rawValue }

    var title: String {
        switch self {
        case .modified:
            "Modified"
        case .title:
            "Title"
        case .wordCount:
            "Words"
        }
    }

    func sort(_ documents: [MarkdownDocument]) -> [MarkdownDocument] {
        switch self {
        case .modified:
            documents.sorted { $0.updatedAt > $1.updatedAt }
        case .title:
            documents.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .wordCount:
            documents.sorted { lhs, rhs in
                if lhs.wordCount == rhs.wordCount {
                    return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }
                return lhs.wordCount > rhs.wordCount
            }
        }
    }
}

enum DocumentFilterOption: String, CaseIterable, Identifiable {
    case all
    case recent
    case unfiled
    case brokenLinks

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            "All"
        case .recent:
            "Recent"
        case .unfiled:
            "Unfiled"
        case .brokenLinks:
            "Broken Links"
        }
    }

    func includes(_ document: MarkdownDocument, links: [MarkdownLink], now: Date = Date()) -> Bool {
        switch self {
        case .all:
            true
        case .recent:
            document.updatedAt >= Calendar.current.date(byAdding: .day, value: -7, to: now, wrappingComponents: false) ?? now
        case .unfiled:
            document.folderId == nil
        case .brokenLinks:
            links.contains { $0.sourceDocumentId == document.id && $0.isBroken }
        }
    }
}
