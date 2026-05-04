//
//  WorkspaceService.swift
//  MarkFlow Studio
//

import Foundation
import SwiftData

enum WorkspaceService {
    private static let requiredDirectoryNames = ["database", "assets", "exports"]

    @MainActor
    static func configureWorkspace(at url: URL, in context: ModelContext) throws {
        let didStartAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        try createWorkspaceDirectories(at: url)
        try writeConfigFile(at: url)
        try persistWorkspaceSettings(for: url, in: context)
    }

    private static func createWorkspaceDirectories(at workspaceURL: URL) throws {
        let fileManager = FileManager.default

        for directoryName in requiredDirectoryNames {
            let directoryURL = workspaceURL.appendingPathComponent(directoryName, isDirectory: true)
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }

    private static func writeConfigFile(at workspaceURL: URL) throws {
        let configURL = workspaceURL.appendingPathComponent("config.json")
        let config = WorkspaceConfig(
            workspaceName: workspaceURL.lastPathComponent,
            directories: requiredDirectoryNames
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(config)
        try data.write(to: configURL, options: [.atomic])
    }

    @MainActor
    private static func persistWorkspaceSettings(for url: URL, in context: ModelContext) throws {
        var descriptor = FetchDescriptor<WorkspaceSettings>()
        descriptor.fetchLimit = 1

        if let existingSettings = try context.fetch(descriptor).first {
            existingSettings.workspaceName = url.lastPathComponent
            existingSettings.storagePath = url.path
        } else {
            let settings = WorkspaceSettings(
                workspaceName: url.lastPathComponent,
                storagePath: url.path
            )
            context.insert(settings)
        }

        try context.save()
    }
}

private struct WorkspaceConfig: Codable {
    let workspaceName: String
    let createdAt: Date
    let directories: [String]

    init(workspaceName: String, directories: [String], createdAt: Date = Date()) {
        self.workspaceName = workspaceName
        self.createdAt = createdAt
        self.directories = directories
    }
}
