//
//  MarkdownTextMetrics.swift
//  MarkFlow Studio
//

import Foundation

enum MarkdownTextMetrics {
    static func wordCount(in content: String) -> Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }

    static func matchCount(in content: String, query: String) -> Int {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return 0 }

        var count = 0
        var searchStart = content.startIndex
        while let range = content.range(of: normalizedQuery, options: [.caseInsensitive, .diacriticInsensitive], range: searchStart..<content.endIndex) {
            count += 1
            searchStart = range.upperBound
        }

        return count
    }

    static func firstMatchingLine(in content: String, query: String) -> String? {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return nil }

        return content
            .components(separatedBy: .newlines)
            .first { line in
                line.range(of: normalizedQuery, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
