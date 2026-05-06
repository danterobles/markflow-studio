# Changelog

## 2026-05-06

### Mayo Mejora — Etapa 1: Workspace Onboarding And Empty States

- Added a dedicated workspace onboarding screen shown before the main app shell when no workspace is configured.
- Explained the local workspace layout (`database/`, `assets/`, `exports/`, and `config.json`) directly in the onboarding UI.
- Added first-use guidance for creating folders, writing Markdown, previewing, and exporting.
- Hid the regular folder/document/editor controls until a workspace is selected to avoid unusable actions during first launch.
- Improved workspace setup error copy with a clearer recovery action.
- Added direct create actions to empty folder and document states on regular and compact layouts.
- Added first-document guidance that introduces wiki-style `[[Document Title]]` links.

### Mayo Mejora — Etapa 2: Compact Navigation And Writing Shortcuts

- Added contextual document-list headers that show whether the user is viewing the whole workspace or a specific folder.
- Updated compact iPhone document navigation titles to use the active folder name or `All Documents`.
- Added a compact breadcrumb strip on iPhone document lists with workspace/folder context and visible document count.
- Added regular-width document-list context with folder/workspace label and visible document count.
- Added quick Markdown insertion from the editor header for common writing actions.
- Added Markdown helpers for wiki links (`[[Document Title]]`) and block quotes.

### Mayo Mejora — Etapa 3: Actionable Internal Links And Backlinks

- Split the internal-links inspector into broken links, resolved outgoing links, and backlinks for clearer navigation.
- Added a summary count for outgoing, backlink, and broken-link states in the document inspector.
- Made broken links more actionable with clearer missing-target copy and create actions grouped first.
- Added backlink rows with source document metadata and direct navigation.
- Added backlink counts to document cards so connected notes are visible from document lists.
- Kept broken-link badges prioritized on cards while surfacing backlink badges when no broken links need attention.

### Mayo Mejora — Etapa 4: Guided Export Preflight

- Added an `ExportPreflightSheet` that turns document and folder export actions into a confirmed review flow.
- Added preflight details for workspace destination, output path, included document count, resolved links, broken links, and asset references.
- Kept document exports selectable across Markdown, HTML, and PDF while explaining each format in the sheet.
- Documented folder export as a Markdown batch export before confirmation.
- Routed existing document and folder export menus through the preflight sheet before writing files.
- Improved export success feedback to include the selected format for document exports.

### Mayo Mejora — Etapa 5: Core Service Unit Tests

- Added a `MarkFlow StudioTests` unit test target to the Xcode project and included it in the existing scheme test action.
- Added in-memory SwiftData test support for service-level tests without touching user workspaces.
- Covered `DocumentService` create, rename, update, duplicate, soft delete, and search behavior.
- Covered `FolderService` hierarchy flattening, document moves, folder moves, and invalid cycle blocking.
- Covered `WikiLinkService` link sync, outgoing links, backlinks, broken-link document creation, and reference updates.
- Covered `ExportService` Markdown, HTML, and folder export behavior with temporary workspace fixtures.
- Renamed the document soft-delete model property to `isSoftDeleted` with `@Attribute(originalName: "isDeleted")` to avoid SwiftData runtime state conflicts while preserving persisted storage naming.

### Mayo Mejora — Etapa 6: Feedback Mapping And ContentView Refactor

- Added `AppFeedbackMessage` as a presentation-layer mapper for common success, warning, and error feedback.
- Extended `AppFeedback.Kind` with informational and warning states so UI feedback can distinguish recoverable problems from failures.
- Routed `ContentView` feedback through typed messages instead of repeated inline strings.
- Added a warning feedback path when linked-document navigation cannot find the target document.
- Kept service types independent from visual presentation while making recoverable errors easier to test.
- Added unit tests for feedback message kinds and recoverable error copy.

### Mayo Mejora — Etapa 7: Liquid Glass Accessibility Pass

- Improved glass panel and capsule surfaces for Increase Contrast and Reduce Transparency accessibility settings.
- Disabled card hover scaling when Reduce Motion is active while preserving selection feedback.
- Strengthened selected and bordered note-card contrast under increased contrast settings.
- Added clearer VoiceOver summaries for document cards, including selected state, word count, updated date, broken links, and backlinks.
- Improved checklist and image accessibility in Markdown preview with explicit labels and values.
- Added current-location VoiceOver state when moving documents between folders.

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

### UI/UX Redesign Pass

- Added a reusable `MarkFlowTheme` with shared accent color, spacing, corner radii, editor width, and adaptive background color.
- Added reusable card and glass capsule modifiers for consistent glassmorphism surfaces, hover feedback, and spring animations.
- Moved the desktop workspace selector into a fixed sidebar footer using `safeAreaInset` and reduced workspace-change visual noise with a compact menu.
- Refined document rows into note-style cards with stronger title hierarchy, two-line previews, metadata pills, accent selection state, and hover affordance.
- Centered the document editor in an 800-point reading column with improved empty states and a calmer layered background.
- Updated the Markdown editor to use a monospaced editor font, line spacing, placeholder text, and a floating formatting toolbar with ultra-thin material.
- Applied the refreshed empty states and accent tint across regular and compact layouts.
- Verified the redesigned app builds successfully for macOS.
- Verified the redesigned app builds successfully for iOS Simulator using `iPhone 17`.

### iPhone Document Creation Fix

- Added explicit `NavigationStack` path handling for the compact iPhone flow so newly created documents open directly in the editor.
- Passed the current folder into iPhone document creation so new notes stay scoped to the visible folder.
- Removed ambiguity in the iPhone document destination by resolving the document from the route ID instead of preferring global selection state.
- Verified the fix builds successfully for macOS.
- Verified the fix builds successfully for iOS Simulator using `iPhone 17`.

### iPhone Existing Document Editing Fix

- Updated the compact document detail layout to avoid embedding the Markdown `TextEditor` inside an outer `ScrollView`, which could block focus and editing gestures on iPhone.
- Kept the wider macOS and iPad detail layout scrollable while giving iPhone a fixed-height editor-first layout.
- Removed the extra simultaneous tap gesture from iPhone document rows and now synchronize selected document state when the route destination appears.
- Verified the fix builds successfully for macOS.
- Verified the fix builds successfully for iOS Simulator using `iPhone 17`.

### Splash Screen

- Added a `RootAppView` that presents a startup splash before loading the main app UI.
- Added `SplashScreenView` using the `bg_app` background asset and `ico_app` icon asset.
- Added a 2.5-second launch presentation with smooth background motion, icon scale/glow, title reveal, and markdown-inspired line accents.
- Added reduced-motion handling so the splash remains polished without unnecessary movement when accessibility settings request it.
- Verified the splash implementation builds successfully for macOS.
- Verified the splash implementation builds successfully for iOS Simulator using `iPhone 17`.

### Distribution Naming

- Set the generated bundle display name to `MarkFlow` for Debug and Release builds without renaming the Xcode project, target, or scheme.
- Updated the splash title and accessibility label to use the distribution name `MarkFlow Writer`.
- Documented that App Store Connect/TestFlight should use `MarkFlow Writer` while the installed app displays as `MarkFlow`.
