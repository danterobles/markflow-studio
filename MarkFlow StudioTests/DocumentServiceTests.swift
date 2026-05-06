//
//  DocumentServiceTests.swift
//  MarkFlow StudioTests
//

import XCTest
@testable import MarkFlow_Studio

@MainActor
final class DocumentServiceTests: XCTestCase {
    func testCreateRenameDuplicateSoftDeleteAndSearch() throws {
        let context = try TestSupport.makeContext()
        let folderId = UUID()

        let document = try DocumentService.createDocument(folderId: folderId, in: context)
        XCTAssertEqual(document.title, "Untitled Document")
        XCTAssertEqual(document.folderId, folderId)
        XCTAssertFalse(document.isSoftDeleted)

        try DocumentService.rename(document, to: "  Architecture Notes  ", in: context)
        XCTAssertEqual(document.title, "Architecture Notes")

        try DocumentService.updateContent(document, content: "SwiftData offline first notes", in: context)
        XCTAssertEqual(document.wordCount, 4)

        let duplicate = try DocumentService.duplicate(document, in: context)
        XCTAssertEqual(duplicate.title, "Architecture Notes Copy")
        XCTAssertEqual(duplicate.content, document.content)
        XCTAssertEqual(duplicate.folderId, folderId)

        let results = DocumentService.search([document, duplicate], query: "offline")
        XCTAssertEqual(Set(results.map(\.id)), Set([document.id, duplicate.id]))

        try DocumentService.softDelete(document, in: context)
        XCTAssertTrue(document.isSoftDeleted)
    }

    func testRenameFallsBackToUntitledDocument() throws {
        let context = try TestSupport.makeContext()
        let document = try DocumentService.createDocument(folderId: nil, in: context)

        try DocumentService.rename(document, to: "   ", in: context)

        XCTAssertEqual(document.title, "Untitled Document")
    }
}
