//
//  MarkdownFolder.swift
//  MarkFlow Studio
//

import Foundation
import SwiftData

@Model
final class MarkdownFolder {
    var id: UUID
    var name: String
    var parentId: UUID?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        parentId: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.parentId = parentId
        self.createdAt = createdAt
    }
}
