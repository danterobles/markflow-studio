//
//  DocumentDetailView.swift
//  MarkFlow Studio
//

import SwiftUI

struct DocumentDetailView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let document: MarkdownDocument?
    let documents: [MarkdownDocument]
    let links: [MarkdownLink]
    let brokenLinkCount: Int
    let actions: DocumentActionContext
    @State private var draftTitle = ""
    @State private var draftContent = ""

    var body: some View {
        Group {
            if let document {
                ZStack {
                    AppBackgroundView()

                    detailContent(for: document)
                }
                .navigationTitle(document.title)
                .tint(MarkFlowTheme.accent)
                .toolbar {
                    ToolbarItemGroup {
                        Menu {
                            ForEach(ExportFormat.allCases) { format in
                                Button {
                                    actions.exportDocument(document, format)
                                } label: {
                                    Text(format.title)
                                }
                            }
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }

                        Button {
                            actions.duplicateDocument(document)
                        } label: {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }

                        Button {
                            actions.moveDocument(document)
                        } label: {
                            Label("Move", systemImage: "folder")
                        }

                        Button(role: .destructive) {
                            actions.deleteDocument(document)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onAppear {
                    syncDrafts(with: document)
                }
                .onChange(of: document.id) { _, _ in
                    syncDrafts(with: document)
                }
                .onChange(of: document.title) { _, title in
                    if draftTitle != title {
                        draftTitle = title
                    }
                }
                .onChange(of: document.content) { _, content in
                    if draftContent != content {
                        draftContent = content
                    }
                }
            } else {
                ZStack {
                    AppBackgroundView()
                    ContentUnavailableView("Select a Document", systemImage: "doc.text.magnifyingglass", description: Text("Choose a note from the list or create a new one to start editing."))
                        .padding(32)
                        .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
                        .padding(24)
                }
            }
        }
    }

    private func syncDrafts(with document: MarkdownDocument) {
        draftTitle = document.title
        draftContent = document.content
    }

    @ViewBuilder
    private func detailContent(for document: MarkdownDocument) -> some View {
        if horizontalSizeClass == .compact {
            detailStack(for: document)
                .frame(maxWidth: MarkFlowTheme.editorMaxWidth, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } else {
            ScrollView {
                detailStack(for: document)
                    .frame(maxWidth: MarkFlowTheme.editorMaxWidth, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func detailStack(for document: MarkdownDocument) -> some View {
        VStack(alignment: .leading, spacing: horizontalSizeClass == .compact ? 18 : 24) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Document title", text: $draftTitle)
                        .font(horizontalSizeClass == .compact ? .title.bold() : .largeTitle.bold())
                        .textFieldStyle(.plain)
                        .onSubmit {
                            actions.renameDocument(document, draftTitle)
                        }

                    Text("Updated \(document.updatedAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if horizontalSizeClass != .compact {
                    InspectorStatusView(document: document, brokenLinkCount: brokenLinkCount)
                }
            }

            MarkdownEditorView(content: $draftContent)
                .onChange(of: draftContent) { _, newValue in
                    actions.updateDocumentContent(document, newValue)
                }

            LinkInspectorView(
                document: document,
                documents: documents,
                links: links,
                actions: actions
            )
        }
    }
}

private struct LinkInspectorView: View {
    let document: MarkdownDocument
    let documents: [MarkdownDocument]
    let links: [MarkdownLink]
    let actions: DocumentActionContext

    private var outgoingLinks: [MarkdownLink] {
        WikiLinkService.outgoingLinks(from: document, links: links)
    }

    private var backlinks: [MarkdownDocument] {
        WikiLinkService.backlinks(to: document, documents: documents, links: links)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Internal Links", systemImage: "link")
                .font(.headline)

            if outgoingLinks.isEmpty && backlinks.isEmpty {
                Text("No wiki links yet. Use [[Document Title]] to connect notes.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                if !outgoingLinks.isEmpty {
                    LinkSectionView(
                        title: "Outgoing",
                        links: outgoingLinks,
                        document: document,
                        actions: actions
                    )
                }

                if !backlinks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Backlinks")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        ForEach(backlinks) { backlink in
                            Button {
                                actions.navigateToDocument(backlink.id)
                            } label: {
                                Label(backlink.title, systemImage: "arrow.uturn.backward")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
            }
        }
        .padding(18)
        .glassPanel(cornerRadius: 24)
    }
}

private struct LinkSectionView: View {
    let title: String
    let links: [MarkdownLink]
    let document: MarkdownDocument
    let actions: DocumentActionContext

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ForEach(links) { link in
                HStack(spacing: 10) {
                    Label(link.targetTitle, systemImage: link.isBroken ? "link.badge.plus" : "doc.text")
                        .foregroundStyle(link.isBroken ? .orange : .primary)
                    Spacer()

                    if let targetDocumentId = link.targetDocumentId, !link.isBroken {
                        Button("Open") {
                            actions.navigateToDocument(targetDocumentId)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    } else {
                        Button("Create") {
                            actions.createDocumentFromBrokenLink(link, document)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
                .font(.callout)
                .padding(10)
                .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
}

private struct InspectorStatusView: View {
    let document: MarkdownDocument
    let brokenLinkCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("\(document.wordCount) words", systemImage: "text.word.spacing")
            Label(brokenLinkCount == 0 ? "Links OK" : "\(brokenLinkCount) broken links", systemImage: brokenLinkCount == 0 ? "checkmark.seal" : "link.badge.plus")
                .foregroundStyle(brokenLinkCount == 0 ? .green : .orange)
        }
        .font(.caption)
        .padding(14)
        .glassPanel(cornerRadius: 18)
        .accessibilityElement(children: .combine)
    }
}
