//
//  FolderService.swift
//  MarkFlow Studio
//

import Foundation
import SwiftData

enum FolderService {
    static func createFolder(named name: String, parentId: UUID?, in context: ModelContext) throws -> MarkdownFolder {
        let folder = MarkdownFolder(name: normalizedName(name), parentId: parentId)
        context.insert(folder)
        try context.save()
        return folder
    }

    static func rename(_ folder: MarkdownFolder, to name: String, in context: ModelContext) throws {
        folder.name = normalizedName(name)
        try context.save()
    }

    static func moveFolder(_ folder: MarkdownFolder, to parentId: UUID?, folders: [MarkdownFolder], in context: ModelContext) throws {
        guard canMoveFolder(folder, to: parentId, in: folders) else {
            throw FolderError.invalidHierarchy
        }

        folder.parentId = parentId
        try context.save()
    }

    static func moveDocument(_ document: MarkdownDocument, to folderId: UUID?, in context: ModelContext) throws {
        document.folderId = folderId
        document.updatedAt = Date()
        try context.save()
    }

    static func flattenedFolders(from folders: [MarkdownFolder]) -> [FolderTreeItem] {
        let groupedFolders = Dictionary(grouping: folders, by: \.parentId)
        return flatten(parentId: nil, depth: 0, groupedFolders: groupedFolders)
    }

    static func canMoveFolder(_ folder: MarkdownFolder, to parentId: UUID?, in folders: [MarkdownFolder]) -> Bool {
        guard let parentId else { return true }
        guard parentId != folder.id else { return false }

        var currentParentId: UUID? = parentId
        while let id = currentParentId {
            if id == folder.id {
                return false
            }
            currentParentId = folders.first { $0.id == id }?.parentId
        }

        return true
    }

    private static func flatten(
        parentId: UUID?,
        depth: Int,
        groupedFolders: [UUID?: [MarkdownFolder]]
    ) -> [FolderTreeItem] {
        let children = (groupedFolders[parentId] ?? [])
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        return children.flatMap { folder in
            [FolderTreeItem(folder: folder, depth: depth)] + flatten(
                parentId: folder.id,
                depth: depth + 1,
                groupedFolders: groupedFolders
            )
        }
    }

    private static func normalizedName(_ name: String) -> String {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? "Untitled Folder" : trimmedName
    }
}

enum FolderError: LocalizedError {
    case invalidHierarchy

    var errorDescription: String? {
        switch self {
        case .invalidHierarchy:
            "A folder cannot be moved into itself or one of its descendants."
        }
    }
}

struct FolderTreeItem: Identifiable {
    let folder: MarkdownFolder
    let depth: Int

    var id: UUID {
        folder.id
    }
}
