//
//  ExportServiceTests.swift
//  MarkFlow StudioTests
//

import XCTest
@testable import MarkFlow_Studio

@MainActor
final class ExportServiceTests: XCTestCase {
    func testMarkdownExportRewritesWikiLinksAndCopiesAssets() throws {
        let workspaceURL = try TestSupport.makeTemporaryWorkspace()
        defer { try? FileManager.default.removeItem(at: workspaceURL) }

        let assetURL = workspaceURL.appendingPathComponent("assets", isDirectory: true).appendingPathComponent("diagram.png")
        try Data("image".utf8).write(to: assetURL)

        let target = MarkdownDocument(title: "Target Note", content: "# Target")
        let source = MarkdownDocument(
            title: "Source Note",
            content: "# Source\n\nSee [[Target Note]].\n\n![Diagram](assets/diagram.png)"
        )
        let workspace = WorkspaceSettings(workspaceName: "Tests", storagePath: workspaceURL.path)

        let fileURL = try ExportService.exportDocument(source, format: .markdown, documents: [source, target], workspace: workspace)
        let exported = try String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertEqual(fileURL.pathExtension, "md")
        XCTAssertTrue(exported.contains("[Target Note](target-note.md)"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.deletingLastPathComponent().appendingPathComponent("assets/diagram.png").path))
    }

    func testHTMLExportEscapesContentAndRewritesWikiLinks() throws {
        let workspaceURL = try TestSupport.makeTemporaryWorkspace()
        defer { try? FileManager.default.removeItem(at: workspaceURL) }

        let target = MarkdownDocument(title: "API Guide", content: "# API")
        let source = MarkdownDocument(title: "HTML Test", content: "# Title <Unsafe>\n\nSee [[API Guide]].")
        let workspace = WorkspaceSettings(workspaceName: "Tests", storagePath: workspaceURL.path)

        let fileURL = try ExportService.exportDocument(source, format: .html, documents: [source, target], workspace: workspace)
        let exported = try String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertEqual(fileURL.pathExtension, "html")
        XCTAssertTrue(exported.contains("<h1>Title &lt;Unsafe&gt;</h1>"))
        XCTAssertTrue(exported.contains("<a href=\"api-guide.html\">API Guide</a>"))
    }

    func testFolderExportIncludesNestedActiveDocumentsOnly() throws {
        let workspaceURL = try TestSupport.makeTemporaryWorkspace()
        defer { try? FileManager.default.removeItem(at: workspaceURL) }

        let root = MarkdownFolder(name: "Root Folder")
        let child = MarkdownFolder(name: "Child", parentId: root.id)
        let activeRootDocument = MarkdownDocument(title: "Root Doc", content: "Root", folderId: root.id)
        let activeChildDocument = MarkdownDocument(title: "Child Doc", content: "Child", folderId: child.id)
        let deletedDocument = MarkdownDocument(title: "Deleted Doc", content: "Deleted", folderId: child.id, isDeleted: true)
        let workspace = WorkspaceSettings(workspaceName: "Tests", storagePath: workspaceURL.path)

        let exportDirectory = try ExportService.exportFolder(
            root,
            documents: [activeRootDocument, activeChildDocument, deletedDocument],
            folders: [root, child],
            workspace: workspace
        )

        XCTAssertTrue(FileManager.default.fileExists(atPath: exportDirectory.appendingPathComponent("root-doc.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: exportDirectory.appendingPathComponent("child-doc.md").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: exportDirectory.appendingPathComponent("deleted-doc.md").path))
    }
}
