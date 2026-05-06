//
//  DocumentListView.swift
//  MarkFlow Studio
//

import SwiftUI

struct DocumentListView: View {
    let documents: [MarkdownDocument]
    let links: [MarkdownLink]
    var contextTitle = "Documents"
    var contextSubtitle: String?
    @Binding var selectedDocumentId: UUID?
    let actions: DocumentActionContext
    @State private var searchText = ""

    private var visibleDocuments: [MarkdownDocument] {
        DocumentService.search(documents, query: searchText)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if visibleDocuments.isEmpty {
                DocumentEmptyStateView(searchText: searchText) {
                    actions.addDocument(nil)
                }
            } else {
                List(selection: $selectedDocumentId) {
                    ForEach(visibleDocuments) { document in
                        DocumentCardView(
                            document: document,
                            isSelected: selectedDocumentId == document.id,
                            brokenLinkCount: brokenLinkCount(for: document),
                            backlinkCount: backlinkCount(for: document)
                        )
                        .tag(Optional(document.id))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .contextMenu {
                            Button {
                                actions.duplicateDocument(document)
                            } label: {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }

                            Button {
                                actions.moveDocument(document)
                            } label: {
                                Label("Move to Folder", systemImage: "folder")
                            }

                            Button(role: .destructive) {
                                actions.deleteDocument(document)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                actions.deleteDocument(document)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                actions.moveDocument(document)
                            } label: {
                                Label("Move", systemImage: "folder")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .contentMargins(.vertical, 12, for: .scrollContent)
                .contentMargins(.horizontal, 10, for: .scrollContent)
            }

            FloatingToolbarView {
                actions.addDocument(nil)
            }
            .padding()
        }
        .background(AppBackgroundView())
        .navigationTitle(contextTitle)
        .safeAreaInset(edge: .top, spacing: 0) {
            if let contextSubtitle {
                DocumentListContextHeader(title: contextTitle, subtitle: contextSubtitle, documentCount: visibleDocuments.count)
            }
        }
        .searchable(text: $searchText, prompt: "Search title or content")
        .tint(MarkFlowTheme.accent)
        .toolbar {
            ToolbarItem {
                Button {
                    actions.addDocument(nil)
                } label: {
                    Label("Add Document", systemImage: "plus")
                }
            }
        }
    }

    private func brokenLinkCount(for document: MarkdownDocument) -> Int {
        links.filter { $0.sourceDocumentId == document.id && $0.isBroken }.count
    }

    private func backlinkCount(for document: MarkdownDocument) -> Int {
        links.filter { $0.targetDocumentId == document.id && !$0.isBroken }.count
    }
}

private struct DocumentListContextHeader: View {
    let title: String
    let subtitle: String
    let documentCount: Int

    var body: some View {
        HStack(spacing: 10) {
            Label(subtitle, systemImage: subtitle == "Folder" ? "folder" : "tray.full")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MarkFlowTheme.accent)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Text("\(documentCount) docs")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.bar)
        .accessibilityElement(children: .combine)
    }
}

struct DocumentEmptyStateView: View {
    let searchText: String
    let addDocument: () -> Void

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 18) {
            ContentUnavailableView(
                isSearching ? "No Results" : "No Documents Yet",
                systemImage: isSearching ? "magnifyingglass" : "doc.text",
                description: Text(isSearching ? "Try a different title or content search." : "Create your first Markdown note, then switch to preview or export when ready.")
            )

            if !isSearching {
                VStack(spacing: 10) {
                    Button(action: addDocument) {
                        Label("Create First Document", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Text("Tip: use [[Document Title]] later to connect notes with wiki links.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: 360)
            }
        }
        .padding(28)
        .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
        .padding(24)
        .accessibilityElement(children: .contain)
    }
}
