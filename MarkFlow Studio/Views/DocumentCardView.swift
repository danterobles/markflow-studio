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

            Text(previewText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    MetadataPill(title: "\(document.wordCount) words", systemImage: "text.word.spacing")
                    MetadataPill(title: updatedDateText, systemImage: "clock")
                    if brokenLinkCount > 0 {
                        MetadataPill(title: "\(brokenLinkCount) broken", systemImage: "link.badge.plus", tint: .orange)
                    }
                }
            }
        }
        .noteCardStyle(isSelected: isSelected)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var previewText: String {
        let trimmedContent = document.content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedContent.isEmpty ? "No content yet." : trimmedContent
    }

    private var updatedDateText: String {
        document.updatedAt.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted))
    }
}

private struct MetadataPill: View {
    let title: String
    let systemImage: String
    var tint: Color = .secondary

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption2.weight(.medium))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.08), in: Capsule(style: .continuous))
    }
}
