//
//  MarkdownLink.swift
//  MarkFlow Studio
//

import Foundation
import SwiftData

@Model
final class MarkdownLink {
    var id: UUID
    var sourceDocumentId: UUID
    var targetDocumentId: UUID?
    var targetTitle: String
    var isBroken: Bool

    init(
        id: UUID = UUID(),
        sourceDocumentId: UUID,
        targetDocumentId: UUID? = nil,
        targetTitle: String,
        isBroken: Bool? = nil
    ) {
        self.id = id
        self.sourceDocumentId = sourceDocumentId
        self.targetDocumentId = targetDocumentId
        self.targetTitle = targetTitle
        self.isBroken = isBroken ?? (targetDocumentId == nil)
    }
}
