# Changelog

## 2026-05-04

### Phase 0: Project Baseline

- Verified the `MarkFlow Studio` scheme builds successfully for macOS.
- Verified the `MarkFlow Studio` scheme builds successfully for iOS Simulator using `iPhone 17`.
- Established the initial app source folder structure under `MarkFlow Studio/`: `Models/`, `ViewModels/`, `Views/`, `Services/`, and `Utilities/`.
- Deferred removal of the template `Item` model until Phase 1 creates and registers the replacement SwiftData domain models.

### Phase 1: SwiftData Domain Model

- Added SwiftData models for `MarkdownDocument`, `MarkdownFolder`, `MarkdownLink`, and `WorkspaceSettings`.
- Registered the product models in `MarkFlow_StudioApp.swift` and removed the template `Item` model dependency.
- Updated `ContentView` to query active `MarkdownDocument` records and use soft delete through `isDeleted`.
- Added preview sample data using an in-memory SwiftData `ModelContainer`.
- Verified the updated app builds successfully for macOS.
- Verified the updated app builds successfully for iOS Simulator using `iPhone 17`.

### Phase 2: Workspace Storage

- Added `WorkspaceService` to configure a user-selected workspace folder.
- Added workspace selection through SwiftUI `fileImporter` with folder access granted by the user.
- Created or validated workspace folders: `database/`, `assets/`, and `exports/`.
- Wrote `config.json` in the workspace root with workspace metadata and expected directory names.
- Persisted the active workspace in SwiftData using `WorkspaceSettings` while keeping filesystem setup isolated in the service layer.
- Displayed the active workspace name/path and workspace configuration errors in `ContentView`.
- Verified the updated app builds successfully for macOS.
- Verified the updated app builds successfully for iOS Simulator using `iPhone 17`.

### Phase 3: App Shell And Navigation

- Replaced the template-style list screen with an adaptive product shell.
- Added macOS/iPad regular-width navigation with sidebar, document list, and document detail columns.
- Added compact iPhone navigation from workspace/folders to document list to document detail.
- Added reusable UI components for workspace status, folder sidebar, document cards, document list, document detail, floating toolbar, feedback banner, and glass-style panels.
- Applied the Liquid Glass visual direction using translucent material panels, soft borders, layered backgrounds, document cards, and a floating toolbar.
- Added visible feedback for workspace setup, document creation, document soft delete, and broken-link counts.
- Verified the updated app builds successfully for macOS.
- Verified the updated app builds successfully for iOS Simulator using `iPhone 17`.

### Phase 4: Folder Management

- Added `FolderService` for creating, renaming, sorting, flattening, and validating folder hierarchies.
- Added nested folder creation with `parentId` support from the sidebar and iPhone folder flow.
- Added folder rename actions through contextual menus.
- Added document moving between folders, including moving documents back to the root workspace.
- Added invalid nesting cycle prevention for folder move logic.
- Updated preview data to include nested folders and folder-assigned documents.
- Verified the updated app builds successfully for macOS.
- Verified the updated app builds successfully for iOS Simulator using `iPhone 17`.

### Phase 5: Document Management

- Added `DocumentService` for document creation, content updates, renaming, duplication, soft delete, and search.
- Reworked document creation and soft delete to save through the service layer instead of inline view logic.
- Added an editable document detail surface with title editing and autosaved Markdown content.
- Added duplicate actions from document lists and the document detail toolbar.
- Added search for active documents by title and content on macOS/iPad document lists and the iPhone document stack.
- Kept `wordCount` current through `MarkdownDocument.updateContent(_:)` during autosave.
- Verified the updated app builds successfully for macOS.
- Verified the updated app builds successfully for iOS Simulator using `iPhone 17`.

### Phase 6: Markdown Editor

- Added `MarkdownEditorView` as the dedicated Markdown editing surface.
- Added editor-only, preview-only, and split modes with an adaptive split layout for wide and narrow screens.
- Added Markdown insertion helpers for headings, lists, checklists, tables, code blocks, links, and images.
- Switched the document detail content area from a raw `TextEditor` to the reusable Markdown editor component.
- Preserved Markdown as plain text by keeping edits bound directly to `MarkdownDocument.content` through the existing autosave flow.
- Kept the preview side as a source preview so full rendered Markdown remains scoped to Phase 7.
- Verified the updated app builds successfully for macOS.
- Verified the updated app builds successfully for iOS Simulator using `iPhone 17`.

### Phase 7: Real-Time Preview

- Added `MarkdownPreviewView` to render Markdown content live from the editor binding.
- Added a lightweight SwiftUI Markdown parser for headings, paragraphs, bullet lists, checklists, tables, fenced code blocks, links, and image placeholders.
- Replaced the Phase 6 source preview with rendered Markdown in preview-only and split modes.
- Preserved responsive split behavior with side-by-side preview on wide layouts and stacked preview on narrow layouts.
- Used adaptive material surfaces, system typography, selectable text, and semantic colors to keep preview readable in light and dark appearances.
- Verified the updated app builds successfully for macOS.
- Verified the updated app builds successfully for iOS Simulator using `iPhone 17`.

### Phase 8: Internal Links And Backlinks

- Added `WikiLinkService` to parse `[[Document Title]]`, sync `MarkdownLink` records, resolve targets, and compute backlinks.
- Synced links on initial app load, document content edits, document creation/duplication, soft delete, and document rename.
- Marked unresolved wiki links as broken with `targetDocumentId = nil` and surfaced create actions for those targets.
- Added an internal-links inspector to the document detail view with outgoing links, broken links, create actions, and backlinks.
- Added navigation from resolved outgoing links and backlinks to their target/source documents.
- Updated document rename behavior to rewrite matching `[[Old Title]]` references to `[[New Title]]` and resync the graph.
- Kept traversal ID-based and one-hop for outgoing/backlink lists to avoid recursive relationship loops.
- Verified the updated app builds successfully for macOS.
- Verified the updated app builds successfully for iOS Simulator using `iPhone 17`.

### Phase 9: Export

- Added `ExportService` for exporting individual documents as Markdown, HTML, and PDF.
- Added folder export that writes active documents as Markdown files.
- Wrote export output under the active workspace `exports/` directory using timestamped folders.
- Converted wiki links to relative links where matching exported targets exist.
- Included referenced workspace assets in export output when Markdown image or asset links are present.
- Added export actions to document detail menus and folder context menus on regular and compact layouts.
- Verified the updated app builds successfully for macOS.
- Verified the updated app builds successfully for iOS Simulator using `iPhone 17`.
