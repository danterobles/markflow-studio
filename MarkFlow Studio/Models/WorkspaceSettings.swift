//
//  WorkspaceSettings.swift
//  MarkFlow Studio
//

import Foundation
import SwiftData

@Model
final class WorkspaceSettings {
    var id: UUID
    var workspaceName: String
    var storagePath: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        workspaceName: String,
        storagePath: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.workspaceName = workspaceName
        self.storagePath = storagePath
        self.createdAt = createdAt
    }
}
