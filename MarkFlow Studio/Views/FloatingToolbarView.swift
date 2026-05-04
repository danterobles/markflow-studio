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

            Label("Autosave ready", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassPanel(cornerRadius: 18)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Floating toolbar")
    }
}
