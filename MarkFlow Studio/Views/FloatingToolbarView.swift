//
//  FloatingToolbarView.swift
//  MarkFlow Studio
//

import SwiftUI

struct FloatingToolbarView: View {
    let addDocument: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: addDocument) {
                Label("New", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .tint(MarkFlowTheme.accent)

            Label("Autosave ready", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .glassCapsule()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Floating toolbar")
    }
}
