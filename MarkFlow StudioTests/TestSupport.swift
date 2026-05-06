//
//  TestSupport.swift
//  MarkFlow StudioTests
//

import Foundation
import SwiftData
@testable import MarkFlow_Studio

enum TestSupport {
    @MainActor
    static func makeContext() throws -> ModelContext {
        let schema = Schema([
            MarkdownDocument.self,
            MarkdownFolder.self,
            MarkdownLink.self,
            WorkspaceSettings.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        return ModelContext(container)
    }

    static func makeTemporaryWorkspace() throws -> URL {
        let workspaceURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("MarkFlowStudioTests-")
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: workspaceURL.appendingPathComponent("assets", isDirectory: true),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: workspaceURL.appendingPathComponent("exports", isDirectory: true),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: workspaceURL.appendingPathComponent("database", isDirectory: true),
            withIntermediateDirectories: true
        )
        return workspaceURL
    }
}
