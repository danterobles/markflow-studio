//
//  AppFeedbackMessageTests.swift
//  MarkFlow StudioTests
//

import XCTest
@testable import MarkFlow_Studio

final class AppFeedbackMessageTests: XCTestCase {
    func testFeedbackMessagesExposePresentationKind() {
        XCTAssertEqual(AppFeedbackMessage.documentCreated.kind, .success)
        XCTAssertEqual(AppFeedbackMessage.linkedDocumentMissing.kind, .warning)
        XCTAssertEqual(AppFeedbackMessage.documentSaveFailed.kind, .error)
    }

    func testExportFailureIncludesRecoverableErrorDescription() {
        let message = AppFeedbackMessage.exportFailed.text(error: ExportError.missingWorkspace)

        XCTAssertEqual(message, "Export failed: Select a workspace before exporting.")
    }

    func testWorkspaceSetupFailureDetailsIncludeNextActionAndUnderlyingError() {
        let message = AppFeedbackMessage.workspaceSetupFailureDetails(for: ExportError.couldNotCreatePDF)

        XCTAssertTrue(message.contains("Choose a folder you can write to"))
        XCTAssertTrue(message.contains("Could not create the PDF export context."))
    }
}
