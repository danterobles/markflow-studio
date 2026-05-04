//
//  DocumentCardView.swift
//  MarkFlow Studio
//

import SwiftUI

struct DocumentCardView: View {
    let document: MarkdownDocument
    let isSelected: Bool
    let brokenLinkCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(document.title)
                    .font(.headline)
                    .lineLimit(2)
                Spacer(minLength: 8)
                if brokenLinkCount > 0 {
                    Label("\(brokenLinkCount)", systemImage: "link.badge.plus")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.orange)
                        .accessibilityLabel("\(brokenLinkCount) broken links")
                }
            }

            Text(document.content.isEmpty ? "No content yet." : document.content)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            HStack(spacing: 10) {
                Label("\(document.wordCount) words", systemImage: "text.word.spacing")
                Text(document.updatedAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(cornerRadius: 20)
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isSelected ? Color.blue.opacity(0.55) : Color.clear)
                .frame(width: 4)
                .padding(.vertical, 10)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
