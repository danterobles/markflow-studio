# MarkFlow Studio

MarkFlow Studio is a universal Markdown editor for macOS, iPadOS, and iOS. The product goal is a fast, modern, offline-first workspace for technical documentation, notes, and personal knowledge, with real-time preview and local-first organization.

## Status

The repository now contains the working MarkFlow Studio MVP foundation. The original Xcode template has been replaced with product SwiftData models, an adaptive SwiftUI app shell, Markdown editing/preview, folder and document management, wiki-style links, export flows, a refreshed glassmorphism UI, and a branded splash screen.

## Product Scope

- Create, edit, rename, duplicate, search, and soft-delete Markdown documents.
- Organize documents with virtual folders and nested folder hierarchies.
- Edit Markdown with helpers for headings, lists, tables, code blocks, links, and images.
- Preview Markdown in real time with split, editor-only, and preview-only modes.
- Support wiki-style internal links using `[[Document Title]]`, broken-link detection, backlinks, and target document creation.
- Export documents or folders to Markdown, HTML, and PDF while preserving assets and relative links.
- Store workspaces locally in a user-selected location compatible with iCloud/Drive.
- Present a branded startup splash screen using the app background and icon assets before entering the main workspace.

## Stack

- SwiftUI
- SwiftData
- MVVM
- Xcode 26.4

## Project Layout

- `MarkFlow Studio.xcodeproj`: Xcode project and `MarkFlow Studio` scheme.
- `MarkFlow Studio/`: app source files. New files under this folder are picked up by the Xcode file-system synchronized group.
- `MarkFlow Studio/Models/`: SwiftData models for documents, folders, links, and workspace settings.
- `MarkFlow Studio/Services/`: workspace, folder, document, wiki-link, and export services.
- `MarkFlow Studio/Views/`: adaptive SwiftUI UI, Markdown editor/preview, splash screen, theme, cards, sidebars, and detail views.
- `MarkFlow Studio/Utilities/`: preview/sample data helpers.
- `MarkFlow Studio/Assets.xcassets/`: app icon, splash background, and icon image assets.
- `docs/`: product, data model, UI, export, internal linking, workspace, and backlog specs.
- `AGENTS.md`: repo-specific instructions for future OpenCode sessions.
- `EXECUTION.md`: implementation plan and checklist.
- `CHANGELOG.md`: implementation history and verified build notes.

## Current Entry Points

- App entrypoint: `MarkFlow Studio/MarkFlow_StudioApp.swift`
- Root startup view: `MarkFlow Studio/Views/SplashScreenView.swift` (`RootAppView`)
- Main app shell/root view: `MarkFlow Studio/ContentView.swift`
- SwiftData models: `MarkdownDocument`, `MarkdownFolder`, `MarkdownLink`, and `WorkspaceSettings`

The template `Item` model has been removed. `MarkFlow_StudioApp.swift` registers the product SwiftData schema and injects the persistent model container into the app.

## Implemented Highlights

- Adaptive navigation: macOS/iPad use `NavigationSplitView`; iPhone uses a compact `NavigationStack` flow.
- Workspace setup: user-selected local/iCloud-compatible folder with `database/`, `assets/`, `exports/`, and `config.json`.
- Folder management: create, rename, nested folders, sorted hierarchy, document moves, and invalid nesting protection.
- Document management: create, edit, autosave, rename, duplicate, search, soft delete, and word count updates.
- Markdown editor: editor-only, preview-only, and split modes with formatting helpers.
- Real-time preview: headings, paragraphs, lists, checklists, tables, code blocks, links, and image placeholders.
- Internal links: `[[Document Title]]` parsing, broken-link detection, target creation, navigation, backlinks, and rename updates.
- Export: single document Markdown/HTML/PDF export and folder Markdown export under workspace `exports/`.
- UI/UX: glassmorphism theme, note cards, hover affordances, floating toolbars, empty states, centered editor, and responsive compact fixes.
- Splash screen: 2.5-second branded animated startup using `bg_app` and `ico_app` assets with reduced-motion support.

## Developer Commands

List targets and schemes:

```sh
xcodebuild -list -project "MarkFlow Studio.xcodeproj"
```

Build for macOS:

```sh
xcodebuild -project "MarkFlow Studio.xcodeproj" -scheme "MarkFlow Studio" -destination 'platform=macOS' build
```

Build for iOS Simulator:

```sh
xcodebuild -project "MarkFlow Studio.xcodeproj" -scheme "MarkFlow Studio" -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## Platform Notes

- Deployment targets are currently set to 26.4 for iOS, macOS, and visionOS/xrOS.
- Local iOS simulators are available at 26.4.1.
- visionOS is listed in project platforms, but the local visionOS 26.4 runtime is not installed.
- App sandboxing is enabled, outgoing network access is disabled, and user-selected files have read/write permission.
- iPhone compact navigation includes explicit route handling so newly created and existing documents open into editable detail views.

## Spec References

- `docs/01-product-spec.md`: product overview and MVP.
- `docs/02-functional-requirements.md`: functional requirements.
- `docs/03-data-model.md`: intended SwiftData model shape.
- `docs/04-ui-guidelines-liquid-glass.md`: Liquid Glass UI direction and platform layouts.
- `docs/05-export-spec.md`: export formats and behavior.
- `docs/06-internal-linking-spec.md`: wiki link syntax and behavior.
- `docs/07-workspace-spec.md`: workspace storage rules.
- `docs/08-backlog.md`: implementation order.
