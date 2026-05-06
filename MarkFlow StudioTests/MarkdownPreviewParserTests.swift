//
//  MarkdownPreviewParserTests.swift
//  MarkFlow StudioTests
//

import XCTest
@testable import MarkFlow_Studio

final class MarkdownPreviewParserTests: XCTestCase {
    func testParserRecognizesCommonTechnicalMarkdownBlocks() {
        let blocks = MarkdownPreviewParser.parse("""
        # Title

        Intro paragraph.

        - First
        - Second

        - [ ] Todo
        - [x] Done

        | Name | Value |
        | --- | --- |
        | API | Stable |

        ```swift
        let value = 42
        ```

        ![Diagram](assets/diagram.png)
        """)

        XCTAssertEqual(blocks.count, 7)
        XCTAssertEqual(blocks.first, .heading(level: 1, text: "Title"))
        XCTAssertTrue(blocks.contains(.paragraph("Intro paragraph.")))
        XCTAssertTrue(blocks.contains(.image(altText: "Diagram", path: "assets/diagram.png")))
    }

    func testListItemIdentitiesAreStableAcrossEquivalentParses() throws {
        let firstBlocks = MarkdownPreviewParser.parse("""
        - First
        - Second

        - [ ] Todo
        - [x] Done
        """)
        let secondBlocks = MarkdownPreviewParser.parse("""
        - First
        - Second

        - [ ] Todo
        - [x] Done
        """)

        XCTAssertEqual(firstBlocks, secondBlocks)

        guard case .bulletList(let bulletItems) = firstBlocks[0],
              case .checklist(let checklistItems) = firstBlocks[1] else {
            return XCTFail("Expected bullet and checklist blocks")
        }

        XCTAssertEqual(bulletItems.map(\.id), [0, 1])
        XCTAssertEqual(checklistItems.map(\.id), [0, 1])
    }
}
