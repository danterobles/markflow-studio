//
//  MarkdownEditorView.swift
//  MarkFlow Studio
//

import SwiftUI

struct MarkdownEditorView: View {
    @Binding var content: String
    @State private var mode: MarkdownEditorMode = .editor

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
            }

            MarkdownFormattingToolbar { helper in
                insert(helper.snippet)
            }

            editorBody
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
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .accessibilityHint("Insert Markdown for \(helper.title.lowercased())")
                }
            }
            .padding(.vertical, 2)
        }
        .accessibilityLabel("Markdown formatting tools")
    }
}

private enum MarkdownHelper: String, CaseIterable, Identifiable {
    case heading
    case bulletList
    case checklist
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
}

private struct MarkdownTextEditor: View {
    @Binding var content: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: $content)
            .font(.system(.body, design: .monospaced))
            .lineSpacing(6)
            .focused($isFocused)
            .scrollContentBackground(.hidden)
            .frame(minHeight: 420)
            .padding(18)
            .glassPanel(cornerRadius: 28)
            .accessibilityLabel("Markdown source editor")
    }
}

#Preview {
    @Previewable @State var content = "# Welcome\n\nStart writing in Markdown."
    MarkdownEditorView(content: $content)
        .padding()
}
