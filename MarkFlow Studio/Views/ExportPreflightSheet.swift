//
//  ExportPreflightSheet.swift
//  MarkFlow Studio
//

import SwiftUI

enum ExportRequest: Identifiable {
    case document(MarkdownDocument, ExportFormat)
    case folder(MarkdownFolder)

    var id: String {
        switch self {
        case .document(let document, let format):
            "document-\(document.id.uuidString)-\(format.rawValue)"
        case .folder(let folder):
            "folder-\(folder.id.uuidString)"
        }
    }
}

struct ExportPreflightSheet: View {
    @Environment(\.dismiss) private var dismiss
    let request: ExportRequest
    let documents: [MarkdownDocument]
    let folders: [MarkdownFolder]
    let links: [MarkdownLink]
    let workspace: WorkspaceSettings?
    let selectWorkspace: () -> Void
    let confirmExport: (ExportRequest) -> Void
    @State private var selectedFormat: ExportFormat

    init(
        request: ExportRequest,
        documents: [MarkdownDocument],
        folders: [MarkdownFolder],
        links: [MarkdownLink],
        workspace: WorkspaceSettings?,
        selectWorkspace: @escaping () -> Void,
        confirmExport: @escaping (ExportRequest) -> Void
    ) {
        self.request = request
        self.documents = documents
        self.folders = folders
        self.links = links
        self.workspace = workspace
        self.selectWorkspace = selectWorkspace
        self.confirmExport = confirmExport
        switch request {
        case .document(_, let format):
            _selectedFormat = State(initialValue: format)
        case .folder:
            _selectedFormat = State(initialValue: .markdown)
        }
    }

    private var exportDocuments: [MarkdownDocument] {
        switch request {
        case .document(let document, _):
            return [document]
        case .folder(let folder):
            let folderIds = descendantFolderIds(for: folder.id).union([folder.id])
            return documents
                .filter { document in
                    guard let folderId = document.folderId else { return false }
                    return folderIds.contains(folderId) && !document.isDeleted
                }
                .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
    }

    private var resolvedLinkCount: Int {
        links.filter { link in
            exportDocuments.contains { $0.id == link.sourceDocumentId } && !link.isBroken
        }.count
    }

    private var brokenLinkCount: Int {
        links.filter { link in
            exportDocuments.contains { $0.id == link.sourceDocumentId } && link.isBroken
        }.count
    }

    private var hasAssetReferences: Bool {
        exportDocuments.contains { $0.content.contains("](") || $0.content.contains("![") }
    }

    private var title: String {
        switch request {
        case .document(let document, _):
            "Export \(document.title)"
        case .folder(let folder):
            "Export \(folder.name)"
        }
    }

    private var outputDescription: String {
        switch request {
        case .document(let document, _):
            "exports/\(slug(document.title))-timestamp/\(slug(document.title)).\(selectedFormat.fileExtension)"
        case .folder(let folder):
            "exports/\(slug(folder.name))-timestamp/*.md"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    formatSection
                    destinationSection
                    preflightSection
                    formatHelpSection
                }
                .padding(24)
            }
            .background(AppBackgroundView())
            .navigationTitle("Export Preflight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Export") {
                        confirmExport(confirmedRequest)
                        dismiss()
                    }
                    .disabled(workspace == nil || exportDocuments.isEmpty)
                }
            }
        }
        .tint(MarkFlowTheme.accent)
    }

    private var confirmedRequest: ExportRequest {
        switch request {
        case .document(let document, _):
            .document(document, selectedFormat)
        case .folder(let folder):
            .folder(folder)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: "square.and.arrow.up")
                .font(.title2.bold())

            Text("Review destination, format, assets, and links before MarkFlow writes files to your workspace exports folder.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
    }

    @ViewBuilder
    private var formatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Format", systemImage: "doc.richtext")
                .font(.headline)

            switch request {
            case .document:
                Picker("Format", selection: $selectedFormat) {
                    ForEach(ExportFormat.allCases) { format in
                        Text(format.title).tag(format)
                    }
                }
                .pickerStyle(.segmented)
            case .folder:
                PreflightStatusRow(title: "Folder export", value: "Markdown files", systemImage: "folder")
            }
        }
        .padding(18)
        .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
    }

    private var destinationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Destination", systemImage: "externaldrive")
                .font(.headline)

            if let workspace {
                PreflightStatusRow(title: "Workspace", value: workspace.workspaceName, systemImage: "folder.fill", tint: MarkFlowTheme.accent)
                PreflightStatusRow(title: "Output", value: outputDescription, systemImage: "arrow.down.doc")
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Workspace required", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Select a writable workspace before exporting.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Button("Select Workspace", action: selectWorkspace)
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(18)
        .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
    }

    private var preflightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Preflight", systemImage: "checklist")
                .font(.headline)

            PreflightStatusRow(title: "Documents", value: "\(exportDocuments.count) included", systemImage: "doc.text")
            PreflightStatusRow(title: "Resolved links", value: "\(resolvedLinkCount)", systemImage: "link", tint: .green)
            PreflightStatusRow(title: "Broken links", value: brokenLinkCount == 0 ? "None" : "\(brokenLinkCount) will remain unresolved", systemImage: "link.badge.plus", tint: brokenLinkCount == 0 ? .green : .orange)
            PreflightStatusRow(title: "Assets", value: hasAssetReferences ? "Workspace assets copied if found" : "No asset references detected", systemImage: "photo")
        }
        .padding(18)
        .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
    }

    private var formatHelpSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Format Notes", systemImage: "info.circle")
                .font(.headline)

            Text(formatDescription)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
    }

    private var formatDescription: String {
        switch request {
        case .folder:
            "Folder export writes each active document as Markdown. Wiki links are preserved as relative Markdown links where possible."
        case .document:
            switch selectedFormat {
            case .markdown:
                "Markdown keeps source text portable and converts resolved wiki links to relative .md links."
            case .html:
                "HTML creates a standalone readable page using MarkFlow's base document styling."
            case .pdf:
                "PDF renders from the HTML export path and is best for sharing fixed-layout snapshots."
            }
        }
    }

    private func descendantFolderIds(for folderId: UUID) -> Set<UUID> {
        var descendants = Set<UUID>()
        var stack = [folderId]

        while let currentId = stack.popLast() {
            let children = folders.filter { $0.parentId == currentId }
            for child in children where !descendants.contains(child.id) {
                descendants.insert(child.id)
                stack.append(child.id)
            }
        }

        return descendants
    }

    private func slug(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let scalars = value.lowercased().unicodeScalars.map { scalar in
            allowed.contains(scalar) ? Character(scalar) : "-"
        }
        let slug = String(scalars).split(separator: "-").joined(separator: "-")
        return slug.isEmpty ? "untitled" : slug
    }
}

private struct PreflightStatusRow: View {
    let title: String
    let value: String
    let systemImage: String
    var tint: Color = .secondary

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .frame(width: 20)
                .accessibilityHidden(true)

            Text(title)
                .font(.callout.weight(.medium))

            Spacer(minLength: 12)

            Text(value)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let folder = MarkdownFolder(name: "Notes")
    let document = MarkdownDocument(title: "Welcome", content: "# Welcome\n\nSee [[Architecture]].", folderId: folder.id)
    let workspace = WorkspaceSettings(workspaceName: "Preview Workspace", storagePath: "/Preview/Workspace")

    ExportPreflightSheet(
        request: .document(document, .markdown),
        documents: [document],
        folders: [folder],
        links: [],
        workspace: workspace,
        selectWorkspace: {},
        confirmExport: { _ in }
    )
}
