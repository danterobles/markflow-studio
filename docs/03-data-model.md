# Data Model

## MarkdownDocument

- id: UUID
- title: String
- content: String
- createdAt: Date
- updatedAt: Date
- folderId: UUID?
- isDeleted: Bool
- wordCount: Int

## MarkdownFolder

- id: UUID
- name: String
- parentId: UUID?
- createdAt: Date

## MarkdownLink

- id: UUID
- sourceDocumentId: UUID
- targetDocumentId: UUID?
- targetTitle: String
- isBroken: Bool

## WorkspaceSettings

- id: UUID
- workspaceName: String
- storagePath: String
- createdAt: Date
