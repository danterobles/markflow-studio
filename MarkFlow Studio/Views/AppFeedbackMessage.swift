//
//  AppFeedbackMessage.swift
//  MarkFlow Studio
//

import Foundation

enum AppFeedbackMessage {
    case workspaceReady
    case workspaceSetupNeedsAttention
    case documentCreated
    case documentCreationFailed
    case documentRenamed
    case documentRenameFailed
    case documentSaveFailed
    case documentDuplicated
    case documentDuplicateFailed
    case documentMovedToTrash
    case documentDeleteFailed
    case folderCreated
    case folderCreationFailed
    case folderRenamed
    case folderRenameFailed
    case documentMoved
    case documentMoveFailed
    case documentExported(format: ExportFormat, fileName: String)
    case folderExported(fileName: String)
    case exportFailed
    case linkedDocumentOpened
    case linkedDocumentMissing
    case linkedDocumentCreated
    case linkedDocumentCreationFailed
    case linkSyncFailed

    var kind: AppFeedback.Kind {
        switch self {
        case .workspaceReady,
             .documentCreated,
             .documentRenamed,
             .documentDuplicated,
             .documentMovedToTrash,
             .folderCreated,
             .folderRenamed,
             .documentMoved,
             .documentExported,
             .folderExported,
             .linkedDocumentOpened,
             .linkedDocumentCreated:
            .success
        case .linkedDocumentMissing:
            .warning
        case .workspaceSetupNeedsAttention,
             .documentCreationFailed,
             .documentRenameFailed,
             .documentSaveFailed,
             .documentDuplicateFailed,
             .documentDeleteFailed,
             .folderCreationFailed,
             .folderRenameFailed,
             .documentMoveFailed,
             .exportFailed,
             .linkedDocumentCreationFailed,
             .linkSyncFailed:
            .error
        }
    }

    func text(error: Error? = nil) -> String {
        switch self {
        case .workspaceReady:
            "Workspace ready"
        case .workspaceSetupNeedsAttention:
            "Workspace setup needs attention"
        case .documentCreated:
            "Document created"
        case .documentCreationFailed:
            "Document creation failed. Check workspace permissions and try again."
        case .documentRenamed:
            "Document renamed"
        case .documentRenameFailed:
            "Document rename failed"
        case .documentSaveFailed:
            "Document save failed"
        case .documentDuplicated:
            "Document duplicated"
        case .documentDuplicateFailed:
            "Document duplication failed"
        case .documentMovedToTrash:
            "Document moved to trash"
        case .documentDeleteFailed:
            "Document delete failed"
        case .folderCreated:
            "Folder created"
        case .folderCreationFailed:
            "Folder creation failed. Check workspace permissions and try again."
        case .folderRenamed:
            "Folder renamed"
        case .folderRenameFailed:
            "Folder rename failed"
        case .documentMoved:
            "Document moved"
        case .documentMoveFailed:
            "Document move failed"
        case .documentExported(let format, let fileName):
            "Exported \(format.title) to \(fileName)"
        case .folderExported(let fileName):
            "Folder exported to \(fileName)"
        case .exportFailed:
            if let error {
                "Export failed: \(error.localizedDescription)"
            } else {
                "Export failed"
            }
        case .linkedDocumentOpened:
            "Linked document opened"
        case .linkedDocumentMissing:
            "Linked document was not found. It may have been moved or deleted."
        case .linkedDocumentCreated:
            "Linked document created"
        case .linkedDocumentCreationFailed:
            "Linked document creation failed"
        case .linkSyncFailed:
            "Link sync failed"
        }
    }

    static func workspaceSetupFailureDetails(for error: Error) -> String {
        "Workspace setup failed. Choose a folder you can write to, then try again. Details: \(error.localizedDescription)"
    }
}
