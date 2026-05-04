# MarkFlow Studio

MarkFlow Studio is a universal Markdown editor for macOS, iPadOS, and iOS. The product goal is a fast, modern, offline-first workspace for technical documentation, notes, and personal knowledge, with real-time preview and local-first organization.

## Status

The repository currently contains a new Xcode SwiftUI/SwiftData app template. The product specification lives in `docs/` and describes the intended MVP and implementation order.

## Product Scope

- Create, edit, rename, duplicate, search, and soft-delete Markdown documents.
- Organize documents with virtual folders and nested folder hierarchies.
- Edit Markdown with helpers for headings, lists, tables, code blocks, links, and images.
- Preview Markdown in real time with split, editor-only, and preview-only modes.
- Support wiki-style internal links using `[[Document Title]]`, broken-link detection, backlinks, and target document creation.
- Export documents or folders to Markdown, HTML, and PDF while preserving assets and relative links.
- Store workspaces locally in a user-selected location compatible with iCloud/Drive.

## Stack

- SwiftUI
- SwiftData
- MVVM
- Xcode 26.4

## Project Layout

- `MarkFlow Studio.xcodeproj`: Xcode project and `MarkFlow Studio` scheme.
- `MarkFlow Studio/`: app source files. New files under this folder are picked up by the Xcode file-system synchronized group.
- `docs/`: product, data model, UI, export, internal linking, workspace, and backlog specs.
- `AGENTS.md`: repo-specific instructions for future OpenCode sessions.
- `EXECUTION.md`: implementation plan and checklist.

## Current Entry Points

- App entrypoint: `MarkFlow Studio/MarkFlow_StudioApp.swift`
- Current root view: `MarkFlow Studio/ContentView.swift`
- Template SwiftData model: `MarkFlow Studio/Item.swift`

The template `Item` model is not the intended product model. The planned SwiftData models are `MarkdownDocument`, `MarkdownFolder`, `MarkdownLink`, and `WorkspaceSettings`.

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

## Spec References

- `docs/01-product-spec.md`: product overview and MVP.
- `docs/02-functional-requirements.md`: functional requirements.
- `docs/03-data-model.md`: intended SwiftData model shape.
- `docs/04-ui-guidelines-liquid-glass.md`: Liquid Glass UI direction and platform layouts.
- `docs/05-export-spec.md`: export formats and behavior.
- `docs/06-internal-linking-spec.md`: wiki link syntax and behavior.
- `docs/07-workspace-spec.md`: workspace storage rules.
- `docs/08-backlog.md`: implementation order.
