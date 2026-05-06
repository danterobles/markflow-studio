//
//  FolderServiceTests.swift
//  MarkFlow StudioTests
//

import XCTest
@testable import MarkFlow_Studio

@MainActor
final class FolderServiceTests: XCTestCase {
    func testHierarchyFlatteningMoveAndCycleBlocking() throws {
        let context = try TestSupport.makeContext()
        let root = try FolderService.createFolder(named: "Root", parentId: nil, in: context)
        let child = try FolderService.createFolder(named: "Child", parentId: root.id, in: context)
        let sibling = try FolderService.createFolder(named: "Sibling", parentId: nil, in: context)
        let folders = [root, child, sibling]

        let flattened = FolderService.flattenedFolders(from: folders)
        XCTAssertEqual(flattened.map { $0.folder.name }, ["Root", "Child", "Sibling"])
        XCTAssertEqual(flattened.first { $0.folder.id == child.id }?.depth, 1)

        XCTAssertFalse(FolderService.canMoveFolder(root, to: child.id, in: folders))
        XCTAssertThrowsError(try FolderService.moveFolder(root, to: child.id, folders: folders, in: context)) { error in
            XCTAssertEqual(error as? FolderError, .invalidHierarchy)
        }

        try FolderService.moveFolder(child, to: sibling.id, folders: folders, in: context)
        XCTAssertEqual(child.parentId, sibling.id)
    }

    func testMoveDocumentUpdatesFolderAndTimestamp() throws {
        let context = try TestSupport.makeContext()
        let folder = try FolderService.createFolder(named: "Inbox", parentId: nil, in: context)
        let document = try DocumentService.createDocument(folderId: nil, in: context)
        let previousUpdate = document.updatedAt

        try FolderService.moveDocument(document, to: folder.id, in: context)

        XCTAssertEqual(document.folderId, folder.id)
        XCTAssertGreaterThanOrEqual(document.updatedAt, previousUpdate)
    }
}
