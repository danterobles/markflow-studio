//
//  FeedbackBannerView.swift
//  MarkFlow Studio
//

import SwiftUI

struct FeedbackBannerView: View {
    let feedback: AppFeedback

    var body: some View {
        Label(feedback.message, systemImage: feedback.kind == .success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
            .font(.callout.weight(.medium))
            .foregroundStyle(feedback.kind == .success ? .green : .red)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassPanel(cornerRadius: 18)
            .accessibilityElement(children: .combine)
    }
}
