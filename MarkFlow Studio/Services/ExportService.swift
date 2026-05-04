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
                return folderIds.contains(folderId) && !document.isDeleted
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
        let body = replacingWikiLinks(in: document.content, documents: documents, extension: "html")
            .components(separatedBy: .newlines)
            .map { line in
                if line.hasPrefix("# ") {
                    return "<h1>\(inlineHTML(String(line.dropFirst(2))))</h1>"
                } else if line.hasPrefix("## ") {
                    return "<h2>\(inlineHTML(String(line.dropFirst(3))))</h2>"
                } else if line.hasPrefix("### ") {
                    return "<h3>\(inlineHTML(String(line.dropFirst(4))))</h3>"
                } else if let image = imageHTML(from: line) {
                    return image
                } else if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return ""
                } else {
                    return "<p>\(inlineHTML(line))</p>"
                }
            }
            .joined(separator: "\n")

        return """
        <!doctype html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>\(escaped(document.title))</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif; line-height: 1.6; max-width: 760px; margin: 48px auto; padding: 0 24px; color: #1f2933; }
            h1, h2, h3 { line-height: 1.2; color: #111827; }
            a { color: #2563eb; }
            code, pre { font-family: "SF Mono", Menlo, monospace; }
          </style>
        </head>
        <body>
        \(body)
        </body>
        </html>
        """
    }

    private static func replacingWikiLinks(in content: String, documents: [MarkdownDocument], extension fileExtension: String) -> String {
        var result = ""
        var searchStart = content.startIndex

        while let openingRange = content[searchStart...].range(of: "[["),
              let closingRange = content[openingRange.upperBound...].range(of: "]]") {
            result += content[searchStart..<openingRange.lowerBound]

            let title = content[openingRange.upperBound..<closingRange.lowerBound]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let target = documents.first(where: { !$0.isDeleted && $0.title.localizedCaseInsensitiveCompare(title) == .orderedSame }) {
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

    private static func inlineHTML(_ value: String) -> String {
        var result = ""
        var searchStart = value.startIndex

        while let openText = value[searchStart...].firstIndex(of: "["),
              let closeText = value[openText...].firstIndex(of: "]") {
            let openURL = value.index(after: closeText)
            guard openURL < value.endIndex,
                  value[openURL] == "(",
                  let closeURL = value[openURL...].firstIndex(of: ")") else {
                break
            }

            result += escaped(String(value[searchStart..<openText]))
            let text = String(value[value.index(after: openText)..<closeText])
            let url = String(value[value.index(after: openURL)..<closeURL])
            result += "<a href=\"\(escaped(url))\">\(escaped(text))</a>"
            searchStart = value.index(after: closeURL)
        }

        result += escaped(String(value[searchStart..<value.endIndex]))
        return result
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
