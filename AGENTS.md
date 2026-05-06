# AGENTS.md

## Project Shape
- This is an Xcode app project, not a Swift Package: open/build `MarkFlow Studio.xcodeproj` with scheme `MarkFlow Studio`.
- Current app entrypoint is `MarkFlow Studio/MarkFlow_StudioApp.swift`; it creates a persistent SwiftData `ModelContainer` and injects it into `ContentView`.
- Current source is still the Xcode template (`ContentView`, `Item`); product intent lives in `docs/` and may be ahead of implementation.
- The Xcode project uses a file-system synchronized source group for `MarkFlow Studio/`, so new source files under that folder are picked up by Xcode without manually editing `project.pbxproj` in typical cases.
- Intended architecture is SwiftUI + SwiftData + MVVM for a universal macOS/iPadOS/iOS Markdown editor.

## Commands
- List schemes/targets: `xcodebuild -list -project "MarkFlow Studio.xcodeproj"`
- Build macOS: `xcodebuild -project "MarkFlow Studio.xcodeproj" -scheme "MarkFlow Studio" -destination 'platform=macOS' build`
- Build iOS simulator: `xcodebuild -project "MarkFlow Studio.xcodeproj" -scheme "MarkFlow Studio" -destination 'platform=iOS Simulator,name=iPhone 17' build`
- There are currently no test targets, lint config, formatter config, CI workflows, or package manifests in the repo.

## Product Specs
- `docs/01-product-spec.md` defines MarkFlow Studio as an offline-first Markdown editor for technical docs, notes, and personal knowledge.
- MVP scope is documents, real-time preview, folders, wiki-style internal links, and basic export.
- `docs/03-data-model.md` names the intended SwiftData domain models: `MarkdownDocument`, `MarkdownFolder`, `MarkdownLink`, and `WorkspaceSettings`; replace the template `Item` model rather than building product features on it.
- Documents use soft delete via `isDeleted`; folder/document/link operations should preserve this behavior.
- Internal links use `[[Document Title]]`; unresolved targets are represented as broken links and should support creating a target document later.
- Workspace storage is user-selected and local/iCloud compatible; keep database, assets, exports, and `config.json` separated as described in `docs/07-workspace-spec.md`.
- Export targets are Markdown, HTML, and PDF; HTML uses a base template/configurable CSS, and PDF renders from HTML.
- `docs/08-backlog.md` gives the intended implementation order: workspace/storage, folders, documents, markdown editor, preview, internal links, export, advanced UI, then testing/release.

## UI Direction
- Follow `docs/04-ui-guidelines-liquid-glass.md`: translucent/glass surfaces, minimal hierarchy, smooth transitions, immediate feedback, and adaptive light/dark theming.
- Platform layouts differ: macOS uses Sidebar | List | Editor/Preview, iPad uses collapsible sidebar + editor, and iPhone uses a stack flow from folders to documents to editor to preview.
- Key UI components called out by the spec are translucent sidebar, document cards, floating toolbar, and side inspector.

## Platform And Build Gotchas
- Target deployment versions are currently 26.4 for iOS, macOS, and visionOS/xrOS; available local simulators are 26.4.1.
- `SUPPORTED_PLATFORMS` includes visionOS, but local `xcodebuild -showdestinations` reports visionOS 26.4 is not installed; prefer macOS or iOS simulator verification unless visionOS support is explicitly requested.
- Sandbox is enabled, network access is disabled, and user-selected files are read/write; workspace/file features should use user-granted file access.

## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- For cross-module "how does X relate to Y" questions, prefer `graphify query "<question>"`, `graphify path "<A>" "<B>"`, or `graphify explain "<concept>"` over grep — these traverse the graph's EXTRACTED + INFERRED edges instead of scanning files
- After modifying code files in this session, run `graphify update .` to keep the graph current (AST-only, no API cost)
