//
//  DocumentActionContext.swift
//  MarkFlow Studio
//

import Foundation

struct DocumentActionContext {
    let addDocument: (UUID?) -> Void
    let renameDocument: (MarkdownDocument, String) -> Void
    let updateDocumentContent: (MarkdownDocument, String) -> Void
    let duplicateDocument: (MarkdownDocument) -> Void
    let deleteDocument: (MarkdownDocument) -> Void
    let moveDocument: (MarkdownDocument) -> Void
    let exportDocument: (MarkdownDocument, ExportFormat) -> Void
    let navigateToDocument: (UUID) -> Void
    let createDocumentFromBrokenLink: (MarkdownLink, MarkdownDocument) -> Void
    let selectWorkspace: () -> Void
}
