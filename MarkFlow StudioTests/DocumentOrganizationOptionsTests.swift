//
//  DocumentOrganizationOptionsTests.swift
//  MarkFlow StudioTests
//

import XCTest
@testable import MarkFlow_Studio

final class DocumentOrganizationOptionsTests: XCTestCase {
    func testSortOptionsOrderDocumentsByModifiedTitleAndWordCount() {
        let older = MarkdownDocument(
            title: "Beta",
            content: "One two",
            updatedAt: Date(timeIntervalSince1970: 10)
        )
        let newer = MarkdownDocument(
            title: "Alpha",
            content: "One two three four",
            updatedAt: Date(timeIntervalSince1970: 20)
        )

        XCTAssertEqual(DocumentSortOption.modified.sort([older, newer]).map(\.title), ["Alpha", "Beta"])
        XCTAssertEqual(DocumentSortOption.title.sort([older, newer]).map(\.title), ["Alpha", "Beta"])
        XCTAssertEqual(DocumentSortOption.wordCount.sort([older, newer]).map(\.title), ["Alpha", "Beta"])
    }

    func testFilterOptionsIncludeRecentUnfiledAndBrokenLinkDocuments() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let folderId = UUID()
        let recent = MarkdownDocument(title: "Recent", updatedAt: now, folderId: folderId)
        let oldUnfiled = MarkdownDocument(
            title: "Old Unfiled",
            updatedAt: Calendar.current.date(byAdding: .day, value: -10, to: now) ?? now,
            folderId: nil
        )
        let brokenLink = MarkdownLink(sourceDocumentId: recent.id, targetTitle: "Missing")

        XCTAssertTrue(DocumentFilterOption.all.includes(oldUnfiled, links: [], now: now))
        XCTAssertTrue(DocumentFilterOption.recent.includes(recent, links: [], now: now))
        XCTAssertFalse(DocumentFilterOption.recent.includes(oldUnfiled, links: [], now: now))
        XCTAssertTrue(DocumentFilterOption.unfiled.includes(oldUnfiled, links: [], now: now))
        XCTAssertTrue(DocumentFilterOption.brokenLinks.includes(recent, links: [brokenLink], now: now))
    }
}
