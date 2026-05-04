# Execution Plan

This checklist turns the specs in `docs/` into an implementation sequence for the MarkFlow Studio MVP.

## Phase 0: Project Baseline

- [x] Confirm the `MarkFlow Studio` scheme builds for macOS.
- [x] Confirm the `MarkFlow Studio` scheme builds for iOS Simulator.
- [x] Decide initial folder structure under `MarkFlow Studio/` for Models, ViewModels, Views, Services, and Utilities.
- [x] Remove the template `Item` dependency once replacement SwiftData models are ready.

## Phase 1: SwiftData Domain Model

- [x] Add `MarkdownDocument` with `id`, `title`, `content`, `createdAt`, `updatedAt`, `folderId`, `isDeleted`, and `wordCount`.
- [x] Add `MarkdownFolder` with `id`, `name`, `parentId`, and `createdAt`.
- [x] Add `MarkdownLink` with `id`, `sourceDocumentId`, `targetDocumentId`, `targetTitle`, and `isBroken`.
- [x] Add `WorkspaceSettings` with `id`, `workspaceName`, `storagePath`, and `createdAt`.
- [x] Update `MarkFlow_StudioApp.swift` to register the product models in the SwiftData schema.
- [x] Ensure document delete behavior is soft delete through `isDeleted`, not destructive deletion.
- [x] Add focused model preview/sample data for SwiftUI previews.

## Phase 2: Workspace Storage

- [x] Build workspace selection flow using user-granted file access.
- [x] Persist selected workspace settings locally.
- [x] Create or validate workspace folders: `database/`, `assets/`, and `exports/`.
- [x] Create or update `config.json` in the workspace root.
- [x] Keep app logic backed by SwiftData; do not make filesystem layout the source of domain truth.
- [x] Handle local/iCloud Drive paths without requiring network access.

## Phase 3: App Shell And Navigation

- [x] Replace template list UI with the product shell.
- [x] Implement macOS layout: sidebar, document list, editor/preview detail.
- [x] Implement iPad layout: collapsible sidebar plus editor.
- [x] Implement iPhone layout: folders to documents to editor to preview stack.
- [x] Apply Liquid Glass direction with translucent sidebar, document cards, floating toolbar, and adaptive light/dark theming.
- [x] Add visible feedback for create, save, delete, move, export, and broken-link states.

## Phase 4: Folder Management

- [x] Create folders.
- [x] Rename folders.
- [x] Support nested folders with `parentId`.
- [x] Move documents between folders.
- [x] Sort and display folders consistently.
- [x] Prevent invalid folder nesting cycles.

## Phase 5: Document Management

- [x] Create documents.
- [x] Edit and autosave document content.
- [x] Rename documents and update `updatedAt`.
- [x] Duplicate documents.
- [x] Soft-delete documents.
- [x] Search active documents by title and content.
- [x] Keep `wordCount` current as content changes.

## Phase 6: Markdown Editor

- [x] Add Markdown text editor surface.
- [x] Add helpers for headings, lists, checklists, tables, code blocks, links, and images.
- [x] Preserve Markdown source as plain text in `MarkdownDocument.content`.
- [x] Add editor-only, preview-only, and split modes.
- [x] Ensure editing behavior works on macOS, iPadOS, and iOS.

## Phase 7: Real-Time Preview

- [x] Render Markdown content in real time.
- [x] Keep preview updates responsive while typing.
- [x] Support headers, lists, checklists, tables, code blocks, links, and images.
- [x] Preserve readable styling in light, dark, and adaptive themes.
- [x] Keep split mode stable across document changes.

## Phase 8: Internal Links And Backlinks

- [x] Parse wiki links using `[[Document Title]]` syntax.
- [x] Create `MarkdownLink` records for links found in document content.
- [x] Resolve links by document title.
- [x] Mark unresolved links with `isBroken = true` and `targetDocumentId = nil`.
- [x] Support creating a target document from a broken link.
- [x] Navigate from resolved links to target documents.
- [x] Show backlinks for the current document.
- [x] Update links when a document is renamed.
- [x] Avoid infinite loops in relationship traversal.

## Phase 9: Export

- [x] Export a single document as Markdown using UTF-8.
- [x] Export a folder as Markdown files.
- [x] Export HTML using a base template and configurable CSS.
- [x] Export PDF by rendering from HTML.
- [x] Include assets in exports when needed.
- [x] Preserve internal links as relative links where possible.
- [x] Write exports under the workspace `exports/` directory or a user-selected destination.

## Phase 10: Testing And Release Readiness

- [ ] Add test target when domain logic is implemented.
- [ ] Add tests for word count, soft delete, folder hierarchy, link parsing, broken-link resolution, and export path handling.
- [ ] Add UI smoke coverage for macOS and iOS Simulator when stable.
- [ ] Build macOS with `xcodebuild -project "MarkFlow Studio.xcodeproj" -scheme "MarkFlow Studio" -destination 'platform=macOS' build`.
- [ ] Build iOS Simulator with `xcodebuild -project "MarkFlow Studio.xcodeproj" -scheme "MarkFlow Studio" -destination 'platform=iOS Simulator,name=iPhone 17' build`.
- [ ] Review sandbox/file-access behavior before release.
- [ ] Decide whether visionOS remains supported before release, since the local visionOS runtime is currently unavailable.

## MVP Exit Criteria

- [ ] A user can select or create a workspace.
- [ ] A user can create folders and documents.
- [ ] A user can edit Markdown and see a real-time preview.
- [ ] A user can navigate and repair `[[Document Title]]` links.
- [ ] A user can export Markdown, HTML, and PDF.
- [ ] Soft-deleted documents are hidden from normal browsing but preserved in persistence.
- [ ] The app builds successfully for macOS and iOS Simulator.
