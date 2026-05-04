//
//  MarkdownDocument.swift
//  MarkFlow Studio
//

import Foundation
import SwiftData

@Model
final class MarkdownDocument {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var folderId: UUID?
    var isDeleted: Bool
    var wordCount: Int

    init(
        id: UUID = UUID(),
        title: String,
        content: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        folderId: UUID? = nil,
        isDeleted: Bool = false,
        wordCount: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.folderId = folderId
        self.isDeleted = isDeleted
        self.wordCount = wordCount ?? Self.countWords(in: content)
    }

    func updateContent(_ content: String, at date: Date = Date()) {
        self.content = content
        updatedAt = date
        wordCount = Self.countWords(in: content)
    }

    func rename(to title: String, at date: Date = Date()) {
        self.title = title
        updatedAt = date
    }

    func softDelete(at date: Date = Date()) {
        isDeleted = true
        updatedAt = date
    }

    private static func countWords(in content: String) -> Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }
}
