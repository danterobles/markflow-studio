# Graph Report - .  (2026-05-06)

## Corpus Check
- 59 files · ~50,059 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 408 nodes · 562 edges · 21 communities (15 shown, 6 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 58 edges (avg confidence: 0.85)
- Token cost: 777 input · 5,550 output

## Community Hubs (Navigation)
- [[_COMMUNITY_SwiftUI View Layer|SwiftUI View Layer]]
- [[_COMMUNITY_App Orchestration Flow|App Orchestration Flow]]
- [[_COMMUNITY_App Icon Variants|App Icon Variants]]
- [[_COMMUNITY_Product Requirements|Product Requirements]]
- [[_COMMUNITY_Markdown Preview Parser|Markdown Preview Parser]]
- [[_COMMUNITY_Format Feedback Types|Format Feedback Types]]
- [[_COMMUNITY_Content View Actions|Content View Actions]]
- [[_COMMUNITY_Export Service Pipeline|Export Service Pipeline]]
- [[_COMMUNITY_Export UI Design|Export UI Design]]
- [[_COMMUNITY_Service Error Handling|Service Error Handling]]
- [[_COMMUNITY_Workspace Folder Models|Workspace Folder Models]]
- [[_COMMUNITY_Document Model Service|Document Model Service]]
- [[_COMMUNITY_Liquid Glass Theme|Liquid Glass Theme]]
- [[_COMMUNITY_Wiki Link Service|Wiki Link Service]]
- [[_COMMUNITY_iPhone Navigation|iPhone Navigation]]
- [[_COMMUNITY_Brand Visual Assets|Brand Visual Assets]]
- [[_COMMUNITY_Workspace UX Feedback|Workspace UX Feedback]]
- [[_COMMUNITY_App Entry Point|App Entry Point]]
- [[_COMMUNITY_Architecture Guidance|Architecture Guidance]]
- [[_COMMUNITY_Document Action Context|Document Action Context]]
- [[_COMMUNITY_Folder Action Context|Folder Action Context]]

## God Nodes (most connected - your core abstractions)
1. `ContentView` - 21 edges
2. `ExportService` - 18 edges
3. `MarkdownPreviewParser` - 13 edges
4. `MarkdownHelper` - 11 edges
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

### Community 0 - "SwiftUI View Layer"
Cohesion: 0.05
Nodes (23): View, AppBackgroundView, DesktopAppShellView, DocumentCardView, MetadataPill, DocumentDetailView, InspectorStatusView, LinkInspectorView (+15 more)

### Community 1 - "App Orchestration Flow"
Cohesion: 0.07
Nodes (45): Liquid Glass UI Direction, Workspace Storage Separation, Layered Adaptive Background, Phased Implementation History, Content View App Orchestrator, Document Action Context, Folder Action Context, Wiki Link Sync Flow (+37 more)

### Community 2 - "App Icon Variants"
Cohesion: 0.05
Nodes (41): MarkFlow Studio 128 Pixel App Icon Variant, Circular Blue Teal Gradient Badge, Small Blue Teal MarkFlow Visual Identity, White M With Upward Arrow Symbol, MarkFlow Studio 16 Pixel App Icon Variant, Tiny Circular Blue Teal Gradient Badge, Tiny Blue Teal MarkFlow Visual Identity, Tiny White M With Upward Arrow Symbol (+33 more)

### Community 3 - "Product Requirements"
Cohesion: 0.08
Nodes (40): MVP Feature Scope, MarkFlow Studio Product Vision, Document CRUD And Search Requirements, Markdown HTML PDF Export Requirements, Folder Hierarchy And Move Requirements, Markdown Editing Helper Requirements, Markdown Preview Mode Requirements, Markdown Document Data Model (+32 more)

### Community 4 - "Markdown Preview Parser"
Cohesion: 0.11
Nodes (13): MarkdownInlineText, MarkdownListItem, MarkdownPreviewBlock, bulletList, checklist, codeBlock, heading, image (+5 more)

### Community 5 - "Format Feedback Types"
Cohesion: 0.09
Nodes (24): CaseIterable, Equatable, Identifiable, ExportFormat, html, markdown, pdf, AppFeedback (+16 more)

### Community 6 - "Content View Actions"
Cohesion: 0.14
Nodes (4): ContentView, FolderSheet, create, rename

### Community 8 - "Export UI Design"
Cohesion: 0.13
Nodes (19): Document and Folder Export, Export File Handling Considerations, Export Formats, Export Spec, HTML Export Pipeline, Internal Link Preservation, PDF From HTML Rendering, Markdown Editor User Experience (+11 more)

### Community 9 - "Service Error Handling"
Cohesion: 0.14
Nodes (8): LocalizedError, ExportError, couldNotCreatePDF, missingWorkspace, FolderError, invalidHierarchy, FolderService, FolderTreeItem

### Community 10 - "Workspace Folder Models"
Cohesion: 0.14
Nodes (6): Codable, MarkdownFolder, WorkspaceSettings, WorkspaceConfig, WorkspaceService, MarkFlowPreviewData

### Community 12 - "Liquid Glass Theme"
Cohesion: 0.16
Nodes (7): ViewModifier, GlassPanelModifier, View, GlassCapsuleStyle, MarkFlowTheme, NoteCardStyle, View

### Community 14 - "iPhone Navigation"
Cohesion: 0.18
Nodes (6): Hashable, DocumentStackView, PhoneAppShellView, PhoneRoute, document, documents

### Community 15 - "Brand Visual Assets"
Cohesion: 0.2
Nodes (10): MarkFlow App Background Asset, Blurred Blue Teal Brand Gradient, Soft Abstract Bokeh Shapes, MarkFlow Transparent Icon Asset, Transparent MarkFlow Symbol Variant, White M With Upward Arrow Symbol, White Circular Ring Outline, Circular Blue Teal Gradient Badge (+2 more)

### Community 16 - "Workspace UX Feedback"
Cohesion: 0.29
Nodes (8): Offline First Markdown Knowledge Editor Objective, Workspace Settings Data Model, Immediate Visual Feedback UX, Separated Workspace Database Assets Exports Config Layout, User Selected Workspace Storage Requirement, App Feedback Model, Feedback Banner View, Workspace Status Card

### Community 18 - "Architecture Guidance"
Cohesion: 0.67
Nodes (3): Project Architecture Guidance, MarkFlow Studio, Offline-First Markdown Workspace

## Knowledge Gaps
- **86 isolated node(s):** `create`, `MarkFlowTheme`, `heading`, `paragraph`, `bulletList` (+81 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FolderTreeItem` connect `Service Error Handling` to `Format Feedback Types`?**
  _High betweenness centrality (0.110) - this node is a cross-community bridge._
- **Why does `MarkdownFolder` connect `Workspace Folder Models` to `Service Error Handling`?**
  _High betweenness centrality (0.099) - this node is a cross-community bridge._
- **What connects `create`, `MarkFlowTheme`, `heading` to the rest of the system?**
  _86 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `SwiftUI View Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `App Orchestration Flow` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._
- **Should `App Icon Variants` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Product Requirements` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._