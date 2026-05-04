//
//  WorkspaceStatusCard.swift
//  MarkFlow Studio
//

import SwiftUI

struct WorkspaceStatusCard: View {
    let workspace: WorkspaceSettings?
    let errorMessage: String?
    let selectWorkspace: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: workspace == nil ? "folder.badge.questionmark" : "folder.fill")
                    .font(.title3)
                    .foregroundStyle(workspace == nil ? Color.secondary : Color.blue)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(workspace?.workspaceName ?? "No workspace selected")
                        .font(.headline)
                    Text(workspace?.storagePath ?? "Select a local or iCloud Drive folder to initialize workspace storage.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityElement(children: .combine)
            }

            Button(action: selectWorkspace) {
                Label(workspace == nil ? "Select Workspace" : "Change Workspace", systemImage: "folder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .glassPanel(cornerRadius: 22)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Workspace")
    }
}
