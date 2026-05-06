# Graph Report - MarkFlow Studio  (2026-05-06)

## Corpus Check
- 33 files · ~52,923 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 419 nodes · 579 edges · 21 communities (15 shown, 6 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 58 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b8307dc0`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]

## God Nodes (most connected - your core abstractions)
1. `ContentView` - 21 edges
2. `ExportService` - 18 edges
3. `MarkdownPreviewParser` - 13 edges
4. `MarkdownHelper` - 13 edges
5. `MarkdownDocument` - 10 edges
6. `WikiLinkService` - 10 edges
7. `FolderService` - 9 edges
8. `MarkdownPreviewBlock` - 8 edges
9. `DocumentService` - 8 edges
10. `Document Export Service` - 8 edges

## Surprising Connections (you probably didn't know these)
- `Workspace Configuration Service` --implements--> `Workspace Storage Separation`  [INFERRED]
  MarkFlow Studio/Services/WorkspaceService.swift → AGENTS.md
- `MVP Foundation` --conceptually_related_to--> `Content View App Orchestrator`  [INFERRED]
  README.md → MarkFlow Studio/ContentView.swift
- `Implementation Sequence` --semantically_similar_to--> `Phased Implementation History`  [INFERRED] [semantically similar]
  EXECUTION.md → CHANGELOG.md
- `Implementation Sequence` --rationale_for--> `Document Management Service`  [INFERRED]
  EXECUTION.md → MarkFlow Studio/Services/DocumentService.swift
- `Implementation Sequence` --rationale_for--> `Folder Management Service`  [INFERRED]
  EXECUTION.md → MarkFlow Studio/Services/FolderService.swift

## Hyperedges (group relationships)
- **SwiftUI Premium UI Principles** — system_prompt_ui_agent_clear_visual_hierarchy, system_prompt_ui_agent_spacing_and_breathing_room, system_prompt_ui_agent_modern_materials_glassmorphism, system_prompt_ui_agent_design_system_consistency [EXTRACTED 1.00]
- **Export Output Pipeline** — 05_export_spec_export_formats, 05_export_spec_html_export_pipeline, 05_export_spec_pdf_from_html_rendering, 05_export_spec_export_file_handling_considerations [EXTRACTED 1.00]
- **Markdown Editor Experience Requirements** — system_prompt_ui_agent_premium_minimal_apple_interfaces, system_prompt_ui_agent_componentized_swiftui_views, 05_export_spec_document_and_folder_export, 05_export_spec_internal_link_preservation, chunk_03_markdown_editor_user_experience [INFERRED 0.74]

## Communities (21 total, 6 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.05
Nodes (29): View, AppBackgroundView, DesktopAppShellView, DocumentCardView, MetadataPill, DocumentDetailView, InspectorStatusView, LinkInspectorView (+21 more)

### Community 1 - "Community 1"
Cohesion: 0.07
Nodes (45): Liquid Glass UI Direction, Workspace Storage Separation, Layered Adaptive Background, Phased Implementation History, Content View App Orchestrator, Document Action Context, Folder Action Context, Wiki Link Sync Flow (+37 more)

### Community 2 - "Community 2"
Cohesion: 0.05
Nodes (43): MarkFlow App Background Asset, Blurred Blue Teal Brand Gradient, Soft Abstract Bokeh Shapes, MarkFlow Transparent Icon Asset, Transparent MarkFlow Symbol Variant, White M With Upward Arrow Symbol, White Circular Ring Outline, MarkFlow Studio 128 Pixel App Icon Variant (+35 more)

### Community 3 - "Community 3"
Cohesion: 0.08
Nodes (40): MVP Feature Scope, MarkFlow Studio Product Vision, Document CRUD And Search Requirements, Markdown HTML PDF Export Requirements, Folder Hierarchy And Move Requirements, Markdown Editing Helper Requirements, Markdown Preview Mode Requirements, Markdown Document Data Model (+32 more)

### Community 4 - "Community 4"
Cohesion: 0.11
Nodes (15): Identifiable, MarkdownChecklistItem, MarkdownInlineText, MarkdownListItem, MarkdownPreviewBlock, bulletList, checklist, codeBlock (+7 more)

### Community 5 - "Community 5"
Cohesion: 0.1
Nodes (9): Equatable, ContentView, FolderSheet, create, rename, AppFeedback, Kind, error (+1 more)

### Community 6 - "Community 6"
Cohesion: 0.11
Nodes (19): CaseIterable, ExportFormat, html, markdown, pdf, MarkdownEditorMode, editor, preview (+11 more)

### Community 8 - "Community 8"
Cohesion: 0.13
Nodes (19): Document and Folder Export, Export File Handling Considerations, Export Formats, Export Spec, HTML Export Pipeline, Internal Link Preservation, PDF From HTML Rendering, Markdown Editor User Experience (+11 more)

### Community 9 - "Community 9"
Cohesion: 0.14
Nodes (8): LocalizedError, ExportError, couldNotCreatePDF, missingWorkspace, FolderError, invalidHierarchy, FolderService, FolderTreeItem

### Community 10 - "Community 10"
Cohesion: 0.14
Nodes (6): Codable, MarkdownFolder, WorkspaceSettings, WorkspaceConfig, WorkspaceService, MarkFlowPreviewData

### Community 12 - "Community 12"
Cohesion: 0.16
Nodes (7): ViewModifier, GlassPanelModifier, View, GlassCapsuleStyle, MarkFlowTheme, NoteCardStyle, View

### Community 14 - "Community 14"
Cohesion: 0.15
Nodes (7): Hashable, CompactBreadcrumbView, DocumentStackView, PhoneAppShellView, PhoneRoute, document, documents

### Community 15 - "Community 15"
Cohesion: 0.29
Nodes (8): Offline First Markdown Knowledge Editor Objective, Workspace Settings Data Model, Immediate Visual Feedback UX, Separated Workspace Database Assets Exports Config Layout, User Selected Workspace Storage Requirement, App Feedback Model, Feedback Banner View, Workspace Status Card

### Community 16 - "Community 16"
Cohesion: 0.25
Nodes (8): MarkFlow Writer 512 Pixel App Icon Variant, Large Circular Blue Teal Gradient Badge, Large Blue Teal MarkFlow Visual Identity, Large White M With Upward Arrow Symbol, MarkFlow Writer 512 Pixel App Icon Variant, Large Circular Blue Teal Gradient Badge, Large Blue Teal MarkFlow Visual Identity, Large White M With Upward Arrow Symbol

### Community 18 - "Community 18"
Cohesion: 0.67
Nodes (3): Project Architecture Guidance, MarkFlow Studio, Offline-First Markdown Workspace

## Knowledge Gaps
- **88 isolated node(s):** `create`, `MarkFlowTheme`, `heading`, `paragraph`, `bulletList` (+83 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FolderTreeItem` connect `Community 9` to `Community 4`?**
  _High betweenness centrality (0.112) - this node is a cross-community bridge._
- **Why does `MarkdownFolder` connect `Community 10` to `Community 9`?**
  _High betweenness centrality (0.100) - this node is a cross-community bridge._
- **What connects `create`, `MarkFlowTheme`, `heading` to the rest of the system?**
  _88 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 3` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._