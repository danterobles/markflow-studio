//
//  WikiLinkServiceTests.swift
//  MarkFlow StudioTests
//

import SwiftData
import XCTest
@testable import MarkFlow_Studio

@MainActor
final class WikiLinkServiceTests: XCTestCase {
    func testSyncLinksBacklinksBrokenLinksAndCreateTarget() throws {
        let context = try TestSupport.makeContext()
        let source = MarkdownDocument(title: "Source", content: "See [[Target]] and [[Missing]].")
        let target = MarkdownDocument(title: "Target", content: "Linked note")
        context.insert(source)
        context.insert(target)
        try context.save()

        try WikiLinkService.syncLinks(for: source, documents: [source, target], links: [], in: context)
        let links = try context.fetch(FetchDescriptor<MarkdownLink>())

        XCTAssertEqual(links.count, 2)
        XCTAssertEqual(WikiLinkService.outgoingLinks(from: source, links: links).map(\.targetTitle), ["Missing", "Target"])
        XCTAssertEqual(WikiLinkService.backlinks(to: target, documents: [source, target], links: links).map(\.id), [source.id])

        let brokenLink = try XCTUnwrap(links.first { $0.isBroken })
        XCTAssertEqual(brokenLink.targetTitle, "Missing")

        let created = try WikiLinkService.createDocument(fromBrokenLink: brokenLink, sourceDocument: source, in: context)
        XCTAssertEqual(created.title, "Missing")
        XCTAssertEqual(created.folderId, source.folderId)
        XCTAssertTrue(created.content.contains("[[Source]]"))
    }

    func testUpdateReferencesRenamesMatchingWikiLinksOnly() throws {
        let context = try TestSupport.makeContext()
        let first = MarkdownDocument(title: "First", content: "[[Old Title]] and [[Other]]")
        let second = MarkdownDocument(title: "Second", content: "No links here")
        context.insert(first)
        context.insert(second)
        try context.save()

        try WikiLinkService.updateReferences(from: "old title", to: "New Title", in: [first, second], context: context)

        XCTAssertEqual(first.content, "[[New Title]] and [[Other]]")
        XCTAssertEqual(second.content, "No links here")
    }
}
