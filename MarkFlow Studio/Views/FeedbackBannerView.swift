//
//  FeedbackBannerView.swift
//  MarkFlow Studio
//

import SwiftUI

struct FeedbackBannerView: View {
    let feedback: AppFeedback

    var body: some View {
        Label(feedback.message, systemImage: iconName)
            .font(.callout.weight(.medium))
            .foregroundStyle(foregroundStyle)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassPanel(cornerRadius: 18)
            .accessibilityElement(children: .combine)
    }

    private var iconName: String {
        switch feedback.kind {
        case .info:
            "info.circle.fill"
        case .success:
            "checkmark.circle.fill"
        case .warning:
            "exclamationmark.circle.fill"
        case .error:
            "exclamationmark.triangle.fill"
        }
    }

    private var foregroundStyle: Color {
        switch feedback.kind {
        case .info:
            .blue
        case .success:
            .green
        case .warning:
            .orange
        case .error:
            .red
        }
    }
}
