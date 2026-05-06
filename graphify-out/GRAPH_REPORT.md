# Graph Report - MarkFlow Studio  (2026-05-06)

## Corpus Check
- 44 files · ~56,987 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 547 nodes · 774 edges · 42 communities (29 shown, 13 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 71 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `6f2d709b`
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
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]

## God Nodes (most connected - your core abstractions)
1. `AppFeedbackMessage` - 28 edges
2. `ContentView` - 23 edges
3. `ExportService` - 19 edges
4. `MarkdownDocument` - 18 edges
5. `MarkdownPreviewParser` - 14 edges
6. `MarkdownHelper` - 14 edges
7. `WikiLinkService` - 11 edges
8. `MarkdownPreviewBlock` - 10 edges
9. `FolderService` - 10 edges
10. `DocumentFilterOption` - 9 edges

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

## Communities (42 total, 13 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.05
Nodes (10): DocumentOrganizationOptionsTests, ExportServiceTests, WikiLinkServiceTests, MarkdownDocument, MarkdownFolder, MarkdownLink, WorkspaceSettings, DocumentService (+2 more)

### Community 1 - "Community 1"
Cohesion: 0.06
Nodes (34): CaseIterable, Identifiable, DocumentFilterOption, all, brokenLinks, recent, unfiled, DocumentSortOption (+26 more)

### Community 2 - "Community 2"
Cohesion: 0.07
Nodes (45): Liquid Glass UI Direction, Workspace Storage Separation, Layered Adaptive Background, Phased Implementation History, Content View App Orchestrator, Document Action Context, Folder Action Context, Wiki Link Sync Flow (+37 more)

### Community 3 - "Community 3"
Cohesion: 0.08
Nodes (40): MVP Feature Scope, MarkFlow Studio Product Vision, Document CRUD And Search Requirements, Markdown HTML PDF Export Requirements, Folder Hierarchy And Move Requirements, Markdown Editing Helper Requirements, Markdown Preview Mode Requirements, Markdown Document Data Model (+32 more)

### Community 4 - "Community 4"
Cohesion: 0.1
Nodes (10): ContentView, FolderSheet, create, rename, AppFeedback, Kind, error, info (+2 more)

### Community 5 - "Community 5"
Cohesion: 0.11
Nodes (15): Equatable, MarkdownChecklistItem, MarkdownInlineText, MarkdownListItem, MarkdownPreviewBlock, bulletList, checklist, codeBlock (+7 more)

### Community 6 - "Community 6"
Cohesion: 0.16
Nodes (10): LocalizedError, ExportError, couldNotCreatePDF, missingWorkspace, ExportFormat, html, markdown, pdf (+2 more)

### Community 7 - "Community 7"
Cohesion: 0.07
Nodes (26): AppFeedbackMessage, documentCreated, documentCreationFailed, documentDeleteFailed, documentDuplicated, documentDuplicateFailed, documentExported, documentMoved (+18 more)

### Community 8 - "Community 8"
Cohesion: 0.13
Nodes (19): Document and Folder Export, Export File Handling Considerations, Export Formats, Export Spec, HTML Export Pipeline, Internal Link Preservation, PDF From HTML Rendering, Markdown Editor User Experience (+11 more)

### Community 9 - "Community 9"
Cohesion: 0.11
Nodes (5): AppFeedbackMessageTests, DocumentServiceTests, FolderServiceTests, MarkdownPreviewParserTests, XCTestCase

### Community 10 - "Community 10"
Cohesion: 0.17
Nodes (7): ViewModifier, GlassPanelModifier, View, GlassCapsuleStyle, MarkFlowTheme, NoteCardStyle, View

### Community 11 - "Community 11"
Cohesion: 0.16
Nodes (7): Hashable, CompactBreadcrumbView, DocumentStackView, PhoneAppShellView, PhoneRoute, document, documents

### Community 12 - "Community 12"
Cohesion: 0.22
Nodes (4): FolderError, invalidHierarchy, FolderService, FolderTreeItem

### Community 13 - "Community 13"
Cohesion: 0.31
Nodes (5): BacklinkSectionView, DocumentDetailView, InspectorStatusView, LinkInspectorView, LinkSectionView

### Community 14 - "Community 14"
Cohesion: 0.31
Nodes (3): Codable, WorkspaceConfig, WorkspaceService

### Community 15 - "Community 15"
Cohesion: 0.32
Nodes (4): DocumentEmptyStateView, DocumentListContextHeader, DocumentListView, DocumentOrganizationBar

### Community 16 - "Community 16"
Cohesion: 0.29
Nodes (8): Offline First Markdown Knowledge Editor Objective, Workspace Settings Data Model, Immediate Visual Feedback UX, Separated Workspace Database Assets Exports Config Layout, User Selected Workspace Storage Requirement, App Feedback Model, Feedback Banner View, Workspace Status Card

### Community 17 - "Community 17"
Cohesion: 0.25
Nodes (8): MarkFlow Writer 512 Pixel App Icon Variant, Large Circular Blue Teal Gradient Badge, Large Blue Teal MarkFlow Visual Identity, Large White M With Upward Arrow Symbol, MarkFlow Writer 512 Pixel App Icon Variant, Large Circular Blue Teal Gradient Badge, Large Blue Teal MarkFlow Visual Identity, Large White M With Upward Arrow Symbol

### Community 18 - "Community 18"
Cohesion: 0.25
Nodes (8): MarkFlow Studio 256 Pixel App Icon Variant, Circular Blue Teal Gradient Badge, Medium Blue Teal MarkFlow Visual Identity, White M With Upward Arrow Symbol, MarkFlow Studio 256 Pixel App Icon Variant, Circular Blue Teal Gradient Badge, Medium Blue Teal MarkFlow Visual Identity, White M With Upward Arrow Symbol

### Community 19 - "Community 19"
Cohesion: 0.25
Nodes (8): MarkFlow Studio 32 Pixel App Icon Variant, Small Circular Blue Teal Gradient Badge, Small Blue Teal MarkFlow Visual Identity, Small White M With Upward Arrow Symbol, MarkFlow Studio 32 Pixel App Icon Variant, Small Circular Blue Teal Gradient Badge, Small Blue Teal MarkFlow Visual Identity, Small White M With Upward Arrow Symbol

### Community 21 - "Community 21"
Cohesion: 0.6
Nodes (4): View, OnboardingStepView, WorkspaceFolderRow, WorkspaceOnboardingView

### Community 22 - "Community 22"
Cohesion: 0.33
Nodes (6): MarkFlow App Background Asset, Blurred Blue Teal Brand Gradient, Soft Abstract Bokeh Shapes, MarkFlow Studio App Icon, Circular Blue Teal Gradient Badge, Blue Teal MarkFlow Visual Identity

### Community 24 - "Community 24"
Cohesion: 0.6
Nodes (3): FolderRowView, FolderSidebarView, SidebarLibraryRow

### Community 25 - "Community 25"
Cohesion: 0.4
Nodes (5): MarkFlow Transparent Icon Asset, Transparent MarkFlow Symbol Variant, White M With Upward Arrow Symbol, White Circular Ring Outline, White M With Upward Arrow Symbol

### Community 31 - "Community 31"
Cohesion: 0.5
Nodes (4): MarkFlow Studio 16 Pixel App Icon Variant, Tiny Circular Blue Teal Gradient Badge, Tiny Blue Teal MarkFlow Visual Identity, Tiny White M With Upward Arrow Symbol

### Community 32 - "Community 32"
Cohesion: 0.5
Nodes (4): MarkFlow Studio App Icon Variant, Circular Blue Teal Gradient Badge, Blue Teal MarkFlow Visual Identity, White M With Upward Arrow Symbol

### Community 33 - "Community 33"
Cohesion: 0.5
Nodes (4): MarkFlow Studio 64 Pixel App Icon Variant, Circular Blue Teal Gradient Badge, Small Blue Teal MarkFlow Visual Identity, White M With Upward Arrow Symbol

### Community 34 - "Community 34"
Cohesion: 0.5
Nodes (4): MarkFlow Studio 128 Pixel App Icon Variant, Circular Blue Teal Gradient Badge, Small Blue Teal MarkFlow Visual Identity, White M With Upward Arrow Symbol

### Community 41 - "Community 41"
Cohesion: 0.67
Nodes (3): Project Architecture Guidance, MarkFlow Studio, Offline-First Markdown Workspace

## Knowledge Gaps
- **121 isolated node(s):** `create`, `document`, `folder`, `heading`, `paragraph` (+116 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FolderTreeItem` connect `Community 12` to `Community 1`?**
  _High betweenness centrality (0.162) - this node is a cross-community bridge._
- **Why does `MarkdownFolder` connect `Community 0` to `Community 12`?**
  _High betweenness centrality (0.154) - this node is a cross-community bridge._
- **Are the 11 inferred relationships involving `MarkdownDocument` (e.g. with `.seed()` and `.createDocument()`) actually correct?**
  _`MarkdownDocument` has 11 INFERRED edges - model-reasoned connections that need verification._
- **What connects `create`, `document`, `folder` to the rest of the system?**
  _121 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._