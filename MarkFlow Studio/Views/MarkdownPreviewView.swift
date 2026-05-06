//
//  MarkdownPreviewView.swift
//  MarkFlow Studio
//

import SwiftUI

struct MarkdownPreviewView: View {
    let content: String
    var updateDelay: Duration = .milliseconds(120)
    @State private var renderedContent = ""
    @State private var blocks: [MarkdownPreviewBlock] = []

    init(content: String, updateDelay: Duration = .milliseconds(120)) {
        self.content = content
        self.updateDelay = updateDelay
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                if blocks.isEmpty {
                    ContentUnavailableView("No Preview", systemImage: "doc.richtext", description: Text("Start writing Markdown to see it rendered here."))
                        .frame(maxWidth: .infinity, minHeight: 320)
                } else {
                    ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                        MarkdownPreviewBlockView(block: block)
                            .equatable()
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 420)
        .glassPanel(cornerRadius: 28)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Markdown preview")
        .task(id: content) {
            await updateBlocks(for: content)
        }
    }

    @MainActor
    private func updateBlocks(for newContent: String) async {
        guard renderedContent != newContent else { return }

        if !renderedContent.isEmpty {
            try? await Task.sleep(for: updateDelay)
        }

        guard !Task.isCancelled, renderedContent != newContent else { return }
        blocks = MarkdownPreviewParser.parse(newContent)
        renderedContent = newContent
    }
}

private struct MarkdownPreviewBlockView: View, Equatable {
    let block: MarkdownPreviewBlock

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.block == rhs.block
    }

    var body: some View {
        switch block {
        case .heading(let level, let text):
            MarkdownInlineText(text)
                .font(font(for: level).bold())
                .padding(.top, level == 1 ? 4 : 2)
        case .paragraph(let text):
            MarkdownInlineText(text)
                .font(.body)
                .lineSpacing(5)
        case .bulletList(let items):
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•")
                            .font(.body.weight(.semibold))
                        MarkdownInlineText(item.text)
                    }
                }
            }
        case .checklist(let items):
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                            .foregroundStyle(item.isChecked ? .green : .secondary)
                        MarkdownInlineText(item.text)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(item.text)
                    .accessibilityValue(item.isChecked ? "Checked" : "Not checked")
                }
            }
        case .table(let rows):
            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 10) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    GridRow {
                        ForEach(rows[rowIndex].indices, id: \.self) { columnIndex in
                            MarkdownInlineText(rows[rowIndex][columnIndex])
                                .font(rowIndex == 0 ? .callout.bold() : .callout)
                                .padding(.vertical, 4)
                        }
                    }
                    if rowIndex == 0 {
                        Divider()
                            .gridCellUnsizedAxes(.horizontal)
                    }
                }
            }
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        case .codeBlock(let language, let code):
            VStack(alignment: .leading, spacing: 10) {
                if !language.isEmpty {
                    Text(language)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text(code)
                    .font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        case .image(let altText, let path):
            HStack(spacing: 12) {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(altText.isEmpty ? "Image" : altText)
                        .font(.headline)
                    Text(path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(altText.isEmpty ? "Image" : "Image: \(altText)")
            .accessibilityValue(path)
        }
    }

    private func font(for level: Int) -> Font {
        switch level {
        case 1:
            .largeTitle
        case 2:
            .title
        case 3:
            .title2
        default:
            .title3
        }
    }
}

private struct MarkdownInlineText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(attributedText)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var attributedText: AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }
}

enum MarkdownPreviewBlock: Equatable {
    case heading(level: Int, text: String)
    case paragraph(String)
    case bulletList([MarkdownListItem])
    case checklist([MarkdownChecklistItem])
    case table([[String]])
    case codeBlock(language: String, code: String)
    case image(altText: String, path: String)
}

struct MarkdownListItem: Identifiable, Equatable {
    let id: Int
    let text: String
}

struct MarkdownChecklistItem: Identifiable, Equatable {
    let id: Int
    let text: String
    let isChecked: Bool
}

enum MarkdownPreviewParser {
    static func parse(_ content: String) -> [MarkdownPreviewBlock] {
        let lines = content.components(separatedBy: .newlines)
        var blocks: [MarkdownPreviewBlock] = []
        var index = 0

        while index < lines.count {
            let line = lines[index]
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            if trimmedLine.isEmpty {
                index += 1
            } else if trimmedLine.hasPrefix("```") {
                let result = parseCodeBlock(lines: lines, startIndex: index)
                blocks.append(result.block)
                index = result.nextIndex
            } else if let heading = parseHeading(trimmedLine) {
                blocks.append(heading)
                index += 1
            } else if let image = parseImage(trimmedLine) {
                blocks.append(image)
                index += 1
            } else if isTableStart(lines: lines, index: index) {
                let result = parseTable(lines: lines, startIndex: index)
                blocks.append(result.block)
                index = result.nextIndex
            } else if isChecklistLine(trimmedLine) {
                let result = parseChecklist(lines: lines, startIndex: index)
                blocks.append(result.block)
                index = result.nextIndex
            } else if isBulletLine(trimmedLine) {
                let result = parseBulletList(lines: lines, startIndex: index)
                blocks.append(result.block)
                index = result.nextIndex
            } else {
                let result = parseParagraph(lines: lines, startIndex: index)
                blocks.append(result.block)
                index = result.nextIndex
            }
        }

        return blocks
    }

    private static func parseCodeBlock(lines: [String], startIndex: Int) -> (block: MarkdownPreviewBlock, nextIndex: Int) {
        let language = lines[startIndex].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "```", with: "")
        var codeLines: [String] = []
        var index = startIndex + 1

        while index < lines.count {
            let line = lines[index]
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                return (.codeBlock(language: language, code: codeLines.joined(separator: "\n")), index + 1)
            }
            codeLines.append(line)
            index += 1
        }

        return (.codeBlock(language: language, code: codeLines.joined(separator: "\n")), index)
    }

    private static func parseHeading(_ line: String) -> MarkdownPreviewBlock? {
        let markerCount = line.prefix { $0 == "#" }.count
        guard (1...6).contains(markerCount), line.dropFirst(markerCount).hasPrefix(" ") else { return nil }
        return .heading(level: markerCount, text: String(line.dropFirst(markerCount)).trimmingCharacters(in: .whitespaces))
    }

    private static func parseImage(_ line: String) -> MarkdownPreviewBlock? {
        guard line.hasPrefix("!["), let closeAlt = line.firstIndex(of: "]") else { return nil }
        let altText = String(line[line.index(line.startIndex, offsetBy: 2)..<closeAlt])
        let pathStart = line.index(after: closeAlt)
        guard pathStart < line.endIndex, line[pathStart] == "(", line.hasSuffix(")") else { return nil }
        let path = String(line[line.index(after: pathStart)..<line.index(before: line.endIndex)])
        return .image(altText: altText, path: path)
    }

    private static func isTableStart(lines: [String], index: Int) -> Bool {
        guard index + 1 < lines.count else { return false }
        let header = lines[index].trimmingCharacters(in: .whitespaces)
        let separator = lines[index + 1].trimmingCharacters(in: .whitespaces)
        return header.contains("|") && separator.contains("|") && separator.replacingOccurrences(of: "|", with: "").allSatisfy { $0 == "-" || $0 == ":" || $0.isWhitespace }
    }

    private static func parseTable(lines: [String], startIndex: Int) -> (block: MarkdownPreviewBlock, nextIndex: Int) {
        var rows: [[String]] = [parseTableRow(lines[startIndex])]
        var index = startIndex + 2

        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            guard line.contains("|") else { break }
            rows.append(parseTableRow(line))
            index += 1
        }

        return (.table(rows), index)
    }

    private static func parseTableRow(_ line: String) -> [String] {
        line.trimmingCharacters(in: CharacterSet(charactersIn: "|"))
            .components(separatedBy: "|")
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }

    private static func isChecklistLine(_ line: String) -> Bool {
        line.hasPrefix("- [ ] ") || line.hasPrefix("- [x] ") || line.hasPrefix("- [X] ")
    }

    private static func parseChecklist(lines: [String], startIndex: Int) -> (block: MarkdownPreviewBlock, nextIndex: Int) {
        var items: [MarkdownChecklistItem] = []
        var index = startIndex

        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            guard isChecklistLine(line) else { break }
            let isChecked = line.hasPrefix("- [x] ") || line.hasPrefix("- [X] ")
            items.append(MarkdownChecklistItem(id: items.count, text: String(line.dropFirst(6)), isChecked: isChecked))
            index += 1
        }

        return (.checklist(items), index)
    }

    private static func isBulletLine(_ line: String) -> Bool {
        line.hasPrefix("- ") || line.hasPrefix("* ")
    }

    private static func parseBulletList(lines: [String], startIndex: Int) -> (block: MarkdownPreviewBlock, nextIndex: Int) {
        var items: [MarkdownListItem] = []
        var index = startIndex

        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            guard isBulletLine(line), !isChecklistLine(line) else { break }
            items.append(MarkdownListItem(id: items.count, text: String(line.dropFirst(2))))
            index += 1
        }

        return (.bulletList(items), index)
    }

    private static func parseParagraph(lines: [String], startIndex: Int) -> (block: MarkdownPreviewBlock, nextIndex: Int) {
        var paragraphLines: [String] = []
        var index = startIndex

        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty,
                  !line.hasPrefix("```"),
                  parseHeading(line) == nil,
                  parseImage(line) == nil,
                  !isChecklistLine(line),
                  !isBulletLine(line),
                  !isTableStart(lines: lines, index: index) else {
                break
            }
            paragraphLines.append(line)
            index += 1
        }

        return (.paragraph(paragraphLines.joined(separator: "\n")), index)
    }
}

#Preview {
    MarkdownPreviewView(content: """
    # Heading

    A paragraph with [a link](https://example.com).

    - First item
    - Second item

    - [ ] Task
    - [x] Done

    | Column | Value |
    | --- | --- |
    | Example | Text |

    ```swift
    let value = 42
    ```

    ![Alt text](assets/image.png)
    """)
    .padding()
}
