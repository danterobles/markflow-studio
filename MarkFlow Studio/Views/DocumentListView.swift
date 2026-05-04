//
//  DocumentListView.swift
//  MarkFlow Studio
//

import SwiftUI

struct DocumentListView: View {
    let documents: [MarkdownDocument]
    let links: [MarkdownLink]
    @Binding var selectedDocumentId: UUID?
    let actions: DocumentActionContext
    @State private var searchText = ""

    private var visibleDocuments: [MarkdownDocument] {
        DocumentService.search(documents, query: searchText)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if visibleDocuments.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "No Documents" : "No Results",
                    systemImage: searchText.isEmpty ? "doc.text" : "magnifyingglass",
                    description: Text(searchText.isEmpty ? "Create a document to start writing Markdown." : "Try a different title or content search.")
                )
                .padding(28)
                .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
                .padding(24)
            } else {
                List(selection: $selectedDocumentId) {
                    ForEach(visibleDocuments) { document in
                        DocumentCardView(
                            document: document,
                            isSelected: selectedDocumentId == document.id,
                            brokenLinkCount: brokenLinkCount(for: document)
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
        .navigationTitle("Documents")
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
}
