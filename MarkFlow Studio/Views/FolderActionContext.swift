//
//  FolderActionContext.swift
//  MarkFlow Studio
//

import Foundation

struct FolderActionContext {
    let createFolder: (UUID?) -> Void
    let renameFolder: (MarkdownFolder) -> Void
    let exportFolder: (MarkdownFolder) -> Void
}
