//
//  MarkdownEditorView.swift
//  MarkFlow Studio
//

import SwiftUI

struct MarkdownEditorView: View {
    @Binding var content: String
    @State private var mode: MarkdownEditorMode = .editor
    @State private var documentSearchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Picker("Editor Mode", selection: $mode) {
                    ForEach(MarkdownEditorMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 360)

                Spacer()

                if mode != .preview {
                    QuickMarkdownMenu { helper in
                        insert(helper.snippet)
                    }
                }
            }

            EditorAssistanceBar(content: content, searchText: $documentSearchText)

            ZStack(alignment: .bottom) {
                editorBody

                if mode != .preview {
                    MarkdownFormattingToolbar { helper in
                        insert(helper.snippet)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    @ViewBuilder
    private var editorBody: some View {
        switch mode {
        case .editor:
            MarkdownTextEditor(content: $content)
        case .preview:
            MarkdownPreviewView(content: content)
        case .split:
            GeometryReader { proxy in
                if proxy.size.width > 760 {
                    HStack(spacing: 16) {
                        MarkdownTextEditor(content: $content)
                        MarkdownPreviewView(content: content)
                    }
                } else {
                    VStack(spacing: 16) {
                        MarkdownTextEditor(content: $content)
                        MarkdownPreviewView(content: content)
                    }
                }
            }
            .frame(minHeight: 520)
        }
    }

    private func insert(_ snippet: String) {
        let separator = content.isEmpty || content.hasSuffix("\n") ? "" : "\n\n"
        content += separator + snippet
    }
}

private struct EditorAssistanceBar: View {
    let content: String
    @Binding var searchText: String
    @FocusState private var isSearchFocused: Bool

    private var wordCount: Int {
        MarkdownTextMetrics.wordCount(in: content)
    }

    private var matchCount: Int {
        MarkdownTextMetrics.matchCount(in: content, query: searchText)
    }

    private var matchingLine: String? {
        MarkdownTextMetrics.firstMatchingLine(in: content, query: searchText)
    }

    private var hasSearch: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Label("\(wordCount) words", systemImage: "text.word.spacing")
                    .foregroundStyle(.secondary)

                Label("Autosaved", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)

                Spacer(minLength: 8)

                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    TextField("Find in document", text: $searchText)
                        .textFieldStyle(.plain)
                        .focused($isSearchFocused)
                        .onSubmit {
                            isSearchFocused = false
                        }

                    if hasSearch {
                        Button {
                            searchText = ""
                        } label: {
                            Label("Clear search", systemImage: "xmark.circle.fill")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.secondary.opacity(0.08), in: Capsule(style: .continuous))
                .frame(maxWidth: 260)
            }
            .font(.caption.weight(.medium))

            if hasSearch {
                HStack(spacing: 8) {
                    Label(matchCount == 1 ? "1 match" : "\(matchCount) matches", systemImage: matchCount == 0 ? "magnifyingglass" : "checkmark.circle")
                        .foregroundStyle(matchCount == 0 ? .orange : MarkFlowTheme.accent)

                    if let matchingLine, !matchingLine.isEmpty {
                        Text(matchingLine)
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassPanel(cornerRadius: 18)
    }
}

enum MarkdownEditorMode: String, CaseIterable, Identifiable {
    case editor
    case preview
    case split

    var id: String { rawValue }

    var title: String {
        switch self {
        case .editor:
            "Editor"
        case .preview:
            "Preview"
        case .split:
            "Split"
        }
    }
}

private struct MarkdownFormattingToolbar: View {
    let insert: (MarkdownHelper) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MarkdownHelper.allCases) { helper in
                    Button {
                        insert(helper)
                    } label: {
                        Label(helper.title, systemImage: helper.systemImage)
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                    .accessibilityHint("Insert Markdown for \(helper.title.lowercased())")
                }
            }
        }
        .glassCapsule()
        .accessibilityLabel("Markdown formatting tools")
    }
}

private struct QuickMarkdownMenu: View {
    let insert: (MarkdownHelper) -> Void

    var body: some View {
        Menu {
            ForEach(MarkdownHelper.quickActions) { helper in
                Button {
                    insert(helper)
                } label: {
                    Label(helper.title, systemImage: helper.systemImage)
                }
            }
        } label: {
            Label("Quick Insert", systemImage: "bolt.fill")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .accessibilityLabel("Quick Markdown insert")
    }
}

private enum MarkdownHelper: String, CaseIterable, Identifiable {
    case heading
    case bulletList
    case checklist
    case quote
    case wikiLink
    case table
    case codeBlock
    case link
    case image

    var id: String { rawValue }

    var title: String {
        switch self {
        case .heading:
            "Heading"
        case .bulletList:
            "List"
        case .checklist:
            "Checklist"
        case .quote:
            "Quote"
        case .wikiLink:
            "Wiki Link"
        case .table:
            "Table"
        case .codeBlock:
            "Code"
        case .link:
            "Link"
        case .image:
            "Image"
        }
    }

    var systemImage: String {
        switch self {
        case .heading:
            "textformat.size"
        case .bulletList:
            "list.bullet"
        case .checklist:
            "checklist"
        case .quote:
            "quote.bubble"
        case .wikiLink:
            "link.badge.plus"
        case .table:
            "tablecells"
        case .codeBlock:
            "chevron.left.forwardslash.chevron.right"
        case .link:
            "link"
        case .image:
            "photo"
        }
    }

    var snippet: String {
        switch self {
        case .heading:
            "## Heading"
        case .bulletList:
            "- First item\n- Second item"
        case .checklist:
            "- [ ] Task\n- [x] Done"
        case .quote:
            "> Quote"
        case .wikiLink:
            "[[Document Title]]"
        case .table:
            "| Column | Value |\n| --- | --- |\n| Example | Text |"
        case .codeBlock:
            "```swift\n// Code\n```"
        case .link:
            "[Link text](https://example.com)"
        case .image:
            "![Alt text](assets/image.png)"
        }
    }

    static var quickActions: [MarkdownHelper] {
        [.heading, .checklist, .wikiLink, .codeBlock, .quote]
    }
}

private struct MarkdownTextEditor: View {
    @Binding var content: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $content)
                .font(MarkFlowTheme.editorFont)
                .lineSpacing(6)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .padding(18)

            if content.isEmpty {
                Text("Start writing Markdown...")
                    .font(MarkFlowTheme.fallbackEditorFont)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 23)
                    .padding(.vertical, 26)
                    .allowsHitTesting(false)
            }
        }
        .frame(minHeight: 420)
        .glassPanel(cornerRadius: 28)
        .accessibilityLabel("Markdown source editor")
    }
}

#Preview {
    @Previewable @State var content = "# Welcome\n\nStart writing in Markdown."
    MarkdownEditorView(content: $content)
        .padding()
}
