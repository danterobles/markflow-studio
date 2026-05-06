//
//  DocumentCardView.swift
//  MarkFlow Studio
//

import SwiftUI

struct DocumentCardView: View {
    let document: MarkdownDocument
    let isSelected: Bool
    let brokenLinkCount: Int
    var backlinkCount = 0

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
                } else if backlinkCount > 0 {
                    Label("\(backlinkCount)", systemImage: "arrow.uturn.backward")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(MarkFlowTheme.accent)
                        .accessibilityLabel("\(backlinkCount) backlinks")
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
                    if backlinkCount > 0 {
                        MetadataPill(title: "\(backlinkCount) back", systemImage: "arrow.uturn.backward", tint: MarkFlowTheme.accent)
                    }
                }
            }
        }
        .noteCardStyle(isSelected: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityValue(isSelected ? "Selected" : "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var previewText: String {
        let trimmedContent = document.content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedContent.isEmpty ? "No content yet." : trimmedContent
    }

    private var updatedDateText: String {
        document.updatedAt.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted))
    }

    private var accessibilitySummary: String {
        var parts = [
            document.title,
            "\(document.wordCount) words",
            "Updated \(updatedDateText)"
        ]

        if brokenLinkCount > 0 {
            parts.append("\(brokenLinkCount) broken links")
        }

        if backlinkCount > 0 {
            parts.append("\(backlinkCount) backlinks")
        }

        return parts.joined(separator: ", ")
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
