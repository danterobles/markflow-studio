//
//  ExportService.swift
//  MarkFlow Studio
//

import CoreGraphics
import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

enum ExportFormat: String, CaseIterable, Identifiable {
    case markdown
    case html
    case pdf

    var id: String { rawValue }

    var title: String {
        switch self {
        case .markdown:
            "Markdown"
        case .html:
            "HTML"
        case .pdf:
            "PDF"
        }
    }

    var fileExtension: String {
        switch self {
        case .markdown:
            "md"
        case .html:
            "html"
        case .pdf:
            "pdf"
        }
    }
}

enum ExportService {
    static func exportDocument(
        _ document: MarkdownDocument,
        format: ExportFormat,
        documents: [MarkdownDocument],
        workspace: WorkspaceSettings
    ) throws -> URL {
        let didStartAccess = startWorkspaceAccess(workspace)
        defer { stopWorkspaceAccess(workspace, didStartAccess: didStartAccess) }

        let exportDirectory = try createExportDirectory(named: slug(document.title), workspace: workspace)
        try copyAssetsIfNeeded(for: [document], workspace: workspace, exportDirectory: exportDirectory)

        let fileURL = exportDirectory.appendingPathComponent(slug(document.title)).appendingPathExtension(format.fileExtension)
        switch format {
        case .markdown:
            try markdownContent(for: document, documents: documents).write(to: fileURL, atomically: true, encoding: .utf8)
        case .html:
            try htmlContent(for: document, documents: documents).write(to: fileURL, atomically: true, encoding: .utf8)
        case .pdf:
            try renderPDF(html: htmlContent(for: document, documents: documents), to: fileURL)
        }

        return fileURL
    }

    static func exportFolder(
        _ folder: MarkdownFolder,
        documents: [MarkdownDocument],
        folders: [MarkdownFolder],
        workspace: WorkspaceSettings
    ) throws -> URL {
        let didStartAccess = startWorkspaceAccess(workspace)
        defer { stopWorkspaceAccess(workspace, didStartAccess: didStartAccess) }

        let folderIds = descendantFolderIds(for: folder.id, folders: folders).union([folder.id])
        let folderDocuments = documents
            .filter { document in
                guard let folderId = document.folderId else { return false }
                return folderIds.contains(folderId) && !document.isSoftDeleted
            }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }

        let exportDirectory = try createExportDirectory(named: slug(folder.name), workspace: workspace)
        try copyAssetsIfNeeded(for: folderDocuments, workspace: workspace, exportDirectory: exportDirectory)

        for document in folderDocuments {
            let fileURL = exportDirectory.appendingPathComponent(slug(document.title)).appendingPathExtension("md")
            try markdownContent(for: document, documents: documents).write(to: fileURL, atomically: true, encoding: .utf8)
        }

        return exportDirectory
    }

    private static func markdownContent(for document: MarkdownDocument, documents: [MarkdownDocument]) -> String {
        replacingWikiLinks(in: document.content, documents: documents, extension: "md")
    }

    private static func htmlContent(for document: MarkdownDocument, documents: [MarkdownDocument]) -> String {
        let linked = replacingWikiLinks(in: document.content, documents: documents, extension: "html")
        let body = renderHTMLBody(linked)

        return """
        <!doctype html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>\(escaped(document.title))</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif; line-height: 1.6; max-width: 760px; margin: 48px auto; padding: 0 24px; color: #1f2933; }
            h1, h2, h3, h4, h5, h6 { line-height: 1.2; color: #111827; margin-top: 1.5em; }
            a { color: #2563eb; }
            code { font-family: "SF Mono", Menlo, monospace; background: #f6f8fa; border-radius: 3px; padding: 2px 5px; font-size: 0.9em; }
            pre { font-family: "SF Mono", Menlo, monospace; background: #f6f8fa; border-radius: 6px; padding: 16px; overflow-x: auto; margin: 1em 0; }
            pre code { background: none; padding: 0; font-size: 1em; }
            table { border-collapse: collapse; width: 100%; margin: 1em 0; }
            th, td { border: 1px solid #d1d5db; padding: 8px 12px; text-align: left; }
            th { background: #f9fafb; font-weight: 600; }
            blockquote { border-left: 4px solid #e5e7eb; margin: 1em 0; padding: 0.5em 1em; color: #6b7280; }
            blockquote p { margin: 0; }
            ul, ol { padding-left: 1.5em; margin: 0.5em 0; }
            ul.checklist { list-style: none; padding-left: 0.25em; }
            ul.checklist li { display: flex; align-items: flex-start; gap: 6px; }
            img { max-width: 100%; height: auto; display: block; margin: 1em 0; }
            figure { margin: 1em 0; }
            figcaption { font-size: 0.875em; color: #6b7280; text-align: center; margin-top: 4px; }
          </style>
        </head>
        <body>
        \(body)
        </body>
        </html>
        """
    }

    // MARK: - HTML Block Renderer

    private static func renderHTMLBody(_ content: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        var html = ""
        var i = 0

        while i < lines.count {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

            // Fenced code block
            if trimmed.hasPrefix("```") {
                let lang = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                i += 1
                while i < lines.count && !lines[i].trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }
                i += 1 // consume closing ```
                let codeContent = codeLines.map { escaped($0) }.joined(separator: "\n")
                let langAttr = lang.isEmpty ? "" : " class=\"language-\(escaped(lang))\""
                html += "<pre><code\(langAttr)>\(codeContent)</code></pre>\n"
                continue
            }

            // Headings h1–h6
            if trimmed.hasPrefix("###### ") {
                html += "<h6>\(inlineHTML(String(trimmed.dropFirst(7))))</h6>\n"; i += 1; continue
            }
            if trimmed.hasPrefix("##### ") {
                html += "<h5>\(inlineHTML(String(trimmed.dropFirst(6))))</h5>\n"; i += 1; continue
            }
            if trimmed.hasPrefix("#### ") {
                html += "<h4>\(inlineHTML(String(trimmed.dropFirst(5))))</h4>\n"; i += 1; continue
            }
            if trimmed.hasPrefix("### ") {
                html += "<h3>\(inlineHTML(String(trimmed.dropFirst(4))))</h3>\n"; i += 1; continue
            }
            if trimmed.hasPrefix("## ") {
                html += "<h2>\(inlineHTML(String(trimmed.dropFirst(3))))</h2>\n"; i += 1; continue
            }
            if trimmed.hasPrefix("# ") {
                html += "<h1>\(inlineHTML(String(trimmed.dropFirst(2))))</h1>\n"; i += 1; continue
            }

            // Blockquote
            if trimmed.hasPrefix("> ") {
                html += "<blockquote>\n"
                while i < lines.count && lines[i].trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("> ") {
                    let inner = String(lines[i].trimmingCharacters(in: .whitespacesAndNewlines).dropFirst(2))
                    html += "<p>\(inlineHTML(inner))</p>\n"
                    i += 1
                }
                html += "</blockquote>\n"
                continue
            }

            // Table (lines starting with |)
            if trimmed.hasPrefix("|") {
                var tableLines: [String] = []
                while i < lines.count && lines[i].trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("|") {
                    tableLines.append(lines[i])
                    i += 1
                }
                html += renderTable(tableLines)
                continue
            }

            // Checklist items (must be checked before unordered list)
            if trimmed.hasPrefix("- [ ] ") || trimmed.hasPrefix("- [x] ") || trimmed.hasPrefix("- [X] ") {
                html += "<ul class=\"checklist\">\n"
                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                    guard t.hasPrefix("- [ ] ") || t.hasPrefix("- [x] ") || t.hasPrefix("- [X] ") else { break }
                    let checked = t.hasPrefix("- [x]") || t.hasPrefix("- [X]")
                    let text = String(t.dropFirst(6))
                    let checkedAttr = checked ? " checked" : ""
                    html += "<li><input type=\"checkbox\" disabled\(checkedAttr)> \(inlineHTML(text))</li>\n"
                    i += 1
                }
                html += "</ul>\n"
                continue
            }

            // Unordered list
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
                html += "<ul>\n"
                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                    guard t.hasPrefix("- ") || t.hasPrefix("* ") || t.hasPrefix("+ ") else { break }
                    html += "<li>\(inlineHTML(String(t.dropFirst(2))))</li>\n"
                    i += 1
                }
                html += "</ul>\n"
                continue
            }

            // Ordered list
            if trimmed.range(of: #"^\d+\. "#, options: .regularExpression) != nil {
                html += "<ol>\n"
                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                    guard let range = t.range(of: #"^\d+\. "#, options: .regularExpression) else { break }
                    html += "<li>\(inlineHTML(String(t[range.upperBound...])))</li>\n"
                    i += 1
                }
                html += "</ol>\n"
                continue
            }

            // Standalone image line
            if let imageTag = imageHTML(from: trimmed) {
                html += "\(imageTag)\n"
                i += 1
                continue
            }

            // Empty line
            if trimmed.isEmpty {
                i += 1
                continue
            }

            // Paragraph
            html += "<p>\(inlineHTML(trimmed))</p>\n"
            i += 1
        }

        return html
    }

    private static func renderTable(_ lines: [String]) -> String {
        func parseRow(_ line: String) -> [String] {
            var cells = line.trimmingCharacters(in: .whitespaces).components(separatedBy: "|")
            if cells.first?.trimmingCharacters(in: .whitespaces).isEmpty == true { cells.removeFirst() }
            if cells.last?.trimmingCharacters(in: .whitespaces).isEmpty == true { cells.removeLast() }
            return cells.map { $0.trimmingCharacters(in: .whitespaces) }
        }
        func isSeparator(_ line: String) -> Bool {
            line.trimmingCharacters(in: .whitespaces)
                .unicodeScalars
                .allSatisfy { CharacterSet(charactersIn: "-:|. ").union(.init(charactersIn: "|")).contains($0) }
        }

        guard !lines.isEmpty else { return "" }
        var html = "<table>\n"
        html += "<thead>\n<tr>\n"
        for cell in parseRow(lines[0]) {
            html += "<th>\(inlineHTML(cell))</th>\n"
        }
        html += "</tr>\n</thead>\n"

        let dataLines = lines.dropFirst().filter { !isSeparator($0) }
        if !dataLines.isEmpty {
            html += "<tbody>\n"
            for line in dataLines {
                html += "<tr>\n"
                for cell in parseRow(line) {
                    html += "<td>\(inlineHTML(cell))</td>\n"
                }
                html += "</tr>\n"
            }
            html += "</tbody>\n"
        }
        html += "</table>\n"
        return html
    }

    private static func replacingWikiLinks(in content: String, documents: [MarkdownDocument], extension fileExtension: String) -> String {
        var result = ""
        var searchStart = content.startIndex

        while let openingRange = content[searchStart...].range(of: "[["),
              let closingRange = content[openingRange.upperBound...].range(of: "]]") {
            result += content[searchStart..<openingRange.lowerBound]

            let title = content[openingRange.upperBound..<closingRange.lowerBound]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let target = documents.first(where: { !$0.isSoftDeleted && $0.title.localizedCaseInsensitiveCompare(title) == .orderedSame }) {
                result += "[\(target.title)](\(slug(target.title)).\(fileExtension))"
            } else {
                result += "[\(title)](\(slug(title)).\(fileExtension))"
            }

            searchStart = closingRange.upperBound
        }

        result += content[searchStart..<content.endIndex]
        return result
    }

    private static func createExportDirectory(named name: String, workspace: WorkspaceSettings) throws -> URL {
        let exportRoot = workspaceURL(for: workspace).appendingPathComponent("exports", isDirectory: true)
        let exportDirectory = exportRoot.appendingPathComponent("\(name)-\(timestamp())", isDirectory: true)
        try FileManager.default.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
        return exportDirectory
    }

    private static func copyAssetsIfNeeded(for documents: [MarkdownDocument], workspace: WorkspaceSettings, exportDirectory: URL) throws {
        guard documents.contains(where: { $0.content.contains("](") || $0.content.contains("![") }) else { return }

        let assetsURL = workspaceURL(for: workspace).appendingPathComponent("assets", isDirectory: true)
        guard FileManager.default.fileExists(atPath: assetsURL.path) else { return }

        let exportAssetsURL = exportDirectory.appendingPathComponent("assets", isDirectory: true)
        if FileManager.default.fileExists(atPath: exportAssetsURL.path) {
            try FileManager.default.removeItem(at: exportAssetsURL)
        }
        try FileManager.default.copyItem(at: assetsURL, to: exportAssetsURL)
    }

    private static func renderPDF(html: String, to url: URL) throws {
        let data = Data(html.utf8)
        let attributedString = try NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        )

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        guard let context = CGContext(url as CFURL, mediaBox: nil, nil) else {
            throw ExportError.couldNotCreatePDF
        }

        context.beginPDFPage([kCGPDFContextMediaBox: pageRect] as CFDictionary)
#if canImport(AppKit)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        attributedString.draw(in: pageRect.insetBy(dx: 48, dy: 48))
        NSGraphicsContext.restoreGraphicsState()
#elseif canImport(UIKit)
        UIGraphicsPushContext(context)
        attributedString.draw(in: pageRect.insetBy(dx: 48, dy: 48))
        UIGraphicsPopContext()
#endif
        context.endPDFPage()
        context.closePDF()
    }

    private static func descendantFolderIds(for folderId: UUID, folders: [MarkdownFolder]) -> Set<UUID> {
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

    private static func slug(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let scalars = value.lowercased().unicodeScalars.map { scalar in
            allowed.contains(scalar) ? Character(scalar) : "-"
        }
        let slug = String(scalars).split(separator: "-").joined(separator: "-")
        return slug.isEmpty ? "untitled" : slug
    }

    private static func escaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private static func inlineHTML(_ raw: String) -> String {
        var out = ""
        var i = raw.startIndex

        while i < raw.endIndex {
            let remaining = raw[i...]

            // Inline code: `...`
            if raw[i] == "`" {
                let codeStart = raw.index(after: i)
                if codeStart < raw.endIndex, let codeEnd = raw[codeStart...].firstIndex(of: "`") {
                    out += "<code>\(escaped(String(raw[codeStart..<codeEnd])))</code>"
                    i = raw.index(after: codeEnd)
                    continue
                }
            }

            // Bold: **...**
            if remaining.hasPrefix("**") {
                let textStart = raw.index(i, offsetBy: 2, limitedBy: raw.endIndex) ?? raw.endIndex
                if textStart < raw.endIndex, let endRange = raw[textStart...].range(of: "**") {
                    out += "<strong>\(escaped(String(raw[textStart..<endRange.lowerBound])))</strong>"
                    i = endRange.upperBound
                    continue
                }
            }

            // Italic: *...*
            if raw[i] == "*" {
                let textStart = raw.index(after: i)
                if textStart < raw.endIndex, let endIdx = raw[textStart...].firstIndex(of: "*") {
                    out += "<em>\(escaped(String(raw[textStart..<endIdx])))</em>"
                    i = raw.index(after: endIdx)
                    continue
                }
            }

            // Link: [text](url)
            if raw[i] == "[" {
                let afterOpen = raw.index(after: i)
                if afterOpen < raw.endIndex, let closeText = raw[afterOpen...].firstIndex(of: "]") {
                    let afterClose = raw.index(after: closeText)
                    if afterClose < raw.endIndex, raw[afterClose] == "(",
                       let closeParen = raw[afterClose...].firstIndex(of: ")") {
                        let text = String(raw[afterOpen..<closeText])
                        let url = String(raw[raw.index(after: afterClose)..<closeParen])
                        out += "<a href=\"\(escaped(url))\">\(escaped(text))</a>"
                        i = raw.index(after: closeParen)
                        continue
                    }
                }
            }

            // Plain character — escape HTML entities
            switch raw[i] {
            case "&": out += "&amp;"
            case "<": out += "&lt;"
            case ">": out += "&gt;"
            case "\"": out += "&quot;"
            default: out += String(raw[i])
            }
            i = raw.index(after: i)
        }

        return out
    }

    private static func imageHTML(from value: String) -> String? {
        guard value.hasPrefix("!["), let closeAlt = value.firstIndex(of: "]") else { return nil }
        let openURL = value.index(after: closeAlt)
        guard openURL < value.endIndex,
              value[openURL] == "(",
              value.hasSuffix(")") else { return nil }

        let altText = String(value[value.index(value.startIndex, offsetBy: 2)..<closeAlt])
        let path = String(value[value.index(after: openURL)..<value.index(before: value.endIndex)])
        return "<figure><img src=\"\(escaped(path))\" alt=\"\(escaped(altText))\"><figcaption>\(escaped(altText))</figcaption></figure>"
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter.string(from: Date())
    }

    private static func workspaceURL(for workspace: WorkspaceSettings) -> URL {
        URL(fileURLWithPath: workspace.storagePath, isDirectory: true)
    }

    private static func startWorkspaceAccess(_ workspace: WorkspaceSettings) -> Bool {
        workspaceURL(for: workspace).startAccessingSecurityScopedResource()
    }

    private static func stopWorkspaceAccess(_ workspace: WorkspaceSettings, didStartAccess: Bool) {
        if didStartAccess {
            workspaceURL(for: workspace).stopAccessingSecurityScopedResource()
        }
    }
}

enum ExportError: LocalizedError {
    case missingWorkspace
    case couldNotCreatePDF

    var errorDescription: String? {
        switch self {
        case .missingWorkspace:
            "Select a workspace before exporting."
        case .couldNotCreatePDF:
            "Could not create the PDF export context."
        }
    }
}
