//
//  MarkdownTextMetricsTests.swift
//  MarkFlow StudioTests
//

import XCTest
@testable import MarkFlow_Studio

final class MarkdownTextMetricsTests: XCTestCase {
    func testWordCountCountsWhitespaceSeparatedWords() {
        XCTAssertEqual(MarkdownTextMetrics.wordCount(in: "# Title\n\nOne two\nthree"), 5)
        XCTAssertEqual(MarkdownTextMetrics.wordCount(in: "   \n\t  "), 0)
    }

    func testMatchCountIsCaseAndDiacriticInsensitive() {
        let content = "Cafe notes\nCAFÉ checklist\nDraft cafe"

        XCTAssertEqual(MarkdownTextMetrics.matchCount(in: content, query: "cafe"), 3)
        XCTAssertEqual(MarkdownTextMetrics.matchCount(in: content, query: "missing"), 0)
        XCTAssertEqual(MarkdownTextMetrics.matchCount(in: content, query: "  "), 0)
    }

    func testFirstMatchingLineReturnsTrimmedLine() {
        let content = "First\n  Target line  \nLast"

        XCTAssertEqual(MarkdownTextMetrics.firstMatchingLine(in: content, query: "target"), "Target line")
        XCTAssertNil(MarkdownTextMetrics.firstMatchingLine(in: content, query: "missing"))
    }
}
