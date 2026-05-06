//
//  ExportServiceTests.swift
//  MarkFlow StudioTests
//

import XCTest
@testable import MarkFlow_Studio

@MainActor
final class ExportServiceTests: XCTestCase {

    // MARK: - Existing coverage

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

    // MARK: - Block-level fixtures

    func testHTMLExportRendersUnorderedList() throws {
        let html = try exportHTML("- Alpha\n- Beta\n- Gamma")
        XCTAssertTrue(html.contains("<ul>"), "Expected <ul> wrapper")
        XCTAssertTrue(html.contains("<li>Alpha</li>"), "Expected Alpha list item")
        XCTAssertTrue(html.contains("<li>Beta</li>"), "Expected Beta list item")
        XCTAssertTrue(html.contains("<li>Gamma</li>"), "Expected Gamma list item")
        XCTAssertTrue(html.contains("</ul>"), "Expected </ul> closing tag")
    }

    func testHTMLExportRendersOrderedList() throws {
        let html = try exportHTML("1. First\n2. Second\n3. Third")
        XCTAssertTrue(html.contains("<ol>"), "Expected <ol> wrapper")
        XCTAssertTrue(html.contains("<li>First</li>"), "Expected First item")
        XCTAssertTrue(html.contains("<li>Second</li>"), "Expected Second item")
        XCTAssertTrue(html.contains("<li>Third</li>"), "Expected Third item")
        XCTAssertTrue(html.contains("</ol>"), "Expected </ol> closing tag")
    }

    func testHTMLExportRendersFencedCodeBlock() throws {
        let content = "```swift\nlet x = 42\nprint(x)\n```"
        let html = try exportHTML(content)
        XCTAssertTrue(html.contains("<pre><code"), "Expected <pre><code> wrapper")
        XCTAssertTrue(html.contains("class=\"language-swift\""), "Expected Swift language class")
        XCTAssertTrue(html.contains("let x = 42"), "Expected code content")
        XCTAssertTrue(html.contains("</code></pre>"), "Expected closing tags")
    }

    func testHTMLExportRendersFencedCodeBlockWithoutLanguage() throws {
        let content = "```\npseudo code\n```"
        let html = try exportHTML(content)
        XCTAssertTrue(html.contains("<pre><code>"), "Expected <pre><code> without language attribute")
        XCTAssertTrue(html.contains("pseudo code"), "Expected code content")
    }

    func testHTMLExportRendersTable() throws {
        let content = "| Name | Age |\n| --- | --- |\n| Alice | 30 |\n| Bob | 25 |"
        let html = try exportHTML(content)
        XCTAssertTrue(html.contains("<table>"), "Expected <table>")
        XCTAssertTrue(html.contains("<thead>"), "Expected <thead>")
        XCTAssertTrue(html.contains("<th>Name</th>"), "Expected Name header cell")
        XCTAssertTrue(html.contains("<th>Age</th>"), "Expected Age header cell")
        XCTAssertTrue(html.contains("<tbody>"), "Expected <tbody>")
        XCTAssertTrue(html.contains("<td>Alice</td>"), "Expected Alice data cell")
        XCTAssertTrue(html.contains("<td>30</td>"), "Expected age data cell")
        XCTAssertTrue(html.contains("<td>Bob</td>"), "Expected Bob data cell")
    }

    func testHTMLExportRendersBlockquote() throws {
        let content = "> This is a quoted passage.\n> It continues here."
        let html = try exportHTML(content)
        XCTAssertTrue(html.contains("<blockquote>"), "Expected <blockquote>")
        XCTAssertTrue(html.contains("<p>This is a quoted passage.</p>"), "Expected quoted paragraph")
        XCTAssertTrue(html.contains("<p>It continues here.</p>"), "Expected second quoted line")
        XCTAssertTrue(html.contains("</blockquote>"), "Expected </blockquote>")
    }

    func testHTMLExportRendersChecklistItems() throws {
        let content = "- [ ] Pending task\n- [x] Completed task\n- [X] Also done"
        let html = try exportHTML(content)
        XCTAssertTrue(html.contains("<ul class=\"checklist\">"), "Expected checklist class")
        XCTAssertTrue(html.contains("type=\"checkbox\" disabled>"), "Expected unchecked item")
        XCTAssertTrue(html.contains("type=\"checkbox\" disabled checked>"), "Expected checked item")
        XCTAssertTrue(html.contains("Pending task"), "Expected pending task text")
        XCTAssertTrue(html.contains("Completed task"), "Expected completed task text")
    }

    func testHTMLExportRendersDeepHeadings() throws {
        let content = "#### H4 Title\n##### H5 Title\n###### H6 Title"
        let html = try exportHTML(content)
        XCTAssertTrue(html.contains("<h4>H4 Title</h4>"), "Expected h4")
        XCTAssertTrue(html.contains("<h5>H5 Title</h5>"), "Expected h5")
        XCTAssertTrue(html.contains("<h6>H6 Title</h6>"), "Expected h6")
    }

    // MARK: - Inline formatting fixtures

    func testHTMLExportRendersInlineBold() throws {
        let html = try exportHTML("Use **bold text** here.")
        XCTAssertTrue(html.contains("<strong>bold text</strong>"), "Expected <strong>")
    }

    func testHTMLExportRendersInlineItalic() throws {
        let html = try exportHTML("Use *italic text* here.")
        XCTAssertTrue(html.contains("<em>italic text</em>"), "Expected <em>")
    }

    func testHTMLExportRendersInlineCode() throws {
        let html = try exportHTML("Call `print()` to output.")
        XCTAssertTrue(html.contains("<code>print()</code>"), "Expected <code>")
    }

    func testHTMLExportEscapesInlineCodeContent() throws {
        let html = try exportHTML("Use `x < y` comparison.")
        XCTAssertTrue(html.contains("<code>x &lt; y</code>"), "Expected escaped content inside <code>")
    }

    // MARK: - PDF export

    func testPDFExportProducesNonEmptyFile() throws {
        let workspaceURL = try TestSupport.makeTemporaryWorkspace()
        defer { try? FileManager.default.removeItem(at: workspaceURL) }

        let doc = MarkdownDocument(
            title: "PDF Fixture",
            content: "# PDF Test\n\nThis document has **bold**, *italic*, and `code`.\n\n- Item A\n- Item B"
        )
        let workspace = WorkspaceSettings(workspaceName: "Tests", storagePath: workspaceURL.path)

        let fileURL = try ExportService.exportDocument(doc, format: .pdf, documents: [doc], workspace: workspace)

        XCTAssertEqual(fileURL.pathExtension, "pdf", "Expected .pdf extension")
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path), "PDF file should exist")
        let data = try Data(contentsOf: fileURL)
        XCTAssertGreaterThan(data.count, 0, "PDF file should not be empty")
    }

    // MARK: - Rich fixture

    func testMarkdownExportWithRichFixturePreservesWikiLinks() throws {
        let workspaceURL = try TestSupport.makeTemporaryWorkspace()
        defer { try? FileManager.default.removeItem(at: workspaceURL) }

        let referenced = MarkdownDocument(title: "Architecture Notes", content: "# Architecture")
        let richFixture = MarkdownDocument(
            title: "Technical Spec",
            content: """
            # Technical Specification

            ## Overview

            See [[Architecture Notes]] for background.

            ## Features

            - Feature Alpha
            - Feature Beta

            ## Data Model

            | Field | Type | Required |
            | --- | --- | --- |
            | id | UUID | Yes |
            | title | String | Yes |

            ## Example

            ```swift
            let doc = MarkdownDocument(title: "Test")
            ```

            > Note: always validate input before saving.

            - [ ] Write unit tests
            - [x] Define data model
            """
        )
        let workspace = WorkspaceSettings(workspaceName: "Tests", storagePath: workspaceURL.path)

        let mdURL = try ExportService.exportDocument(
            richFixture, format: .markdown,
            documents: [richFixture, referenced],
            workspace: workspace
        )
        let markdown = try String(contentsOf: mdURL, encoding: .utf8)
        XCTAssertTrue(markdown.contains("[Architecture Notes](architecture-notes.md)"), "Wiki link should be rewritten in Markdown export")
        XCTAssertFalse(markdown.contains("[[Architecture Notes]]"), "Raw wiki syntax should not remain in Markdown export")

        let htmlURL = try ExportService.exportDocument(
            richFixture, format: .html,
            documents: [richFixture, referenced],
            workspace: workspace
        )
        let html = try String(contentsOf: htmlURL, encoding: .utf8)
        XCTAssertTrue(html.contains("<h1>Technical Specification</h1>"), "h1 rendered")
        XCTAssertTrue(html.contains("<h2>Overview</h2>"), "h2 rendered")
        XCTAssertTrue(html.contains("<a href=\"architecture-notes.html\">Architecture Notes</a>"), "Wiki link rewritten in HTML export")
        XCTAssertTrue(html.contains("<ul>"), "Unordered list rendered")
        XCTAssertTrue(html.contains("<table>"), "Table rendered")
        XCTAssertTrue(html.contains("<pre><code"), "Code block rendered")
        XCTAssertTrue(html.contains("<blockquote>"), "Blockquote rendered")
        XCTAssertTrue(html.contains("<ul class=\"checklist\">"), "Checklist rendered")
    }
}

// MARK: - Helpers

private extension ExportServiceTests {
    func exportHTML(_ content: String) throws -> String {
        let workspaceURL = try TestSupport.makeTemporaryWorkspace()
        defer { try? FileManager.default.removeItem(at: workspaceURL) }

        let doc = MarkdownDocument(title: "Fixture", content: content)
        let workspace = WorkspaceSettings(workspaceName: "Tests", storagePath: workspaceURL.path)
        let fileURL = try ExportService.exportDocument(doc, format: .html, documents: [doc], workspace: workspace)
        return try String(contentsOf: fileURL, encoding: .utf8)
    }
}
