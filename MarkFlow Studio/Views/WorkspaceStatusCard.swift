//
//  WorkspaceStatusCard.swift
//  MarkFlow Studio
//

import SwiftUI

struct WorkspaceStatusCard: View {
    let workspace: WorkspaceSettings?
    let errorMessage: String?
    let selectWorkspace: () -> Void
    var isCompact = false

    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 8 : 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: workspace == nil ? "folder.badge.questionmark" : "folder.fill")
                    .font(isCompact ? .body : .title3)
                    .foregroundStyle(workspace == nil ? Color.secondary : MarkFlowTheme.accent)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(workspace?.workspaceName ?? "No workspace selected")
                        .font(isCompact ? .subheadline.weight(.semibold) : .headline)
                    Text(workspace?.storagePath ?? "Select a local or iCloud Drive folder to initialize workspace storage.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(isCompact ? 1 : 2)
                }
            }

            if let errorMessage, !isCompact {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityElement(children: .combine)
            }

            if isCompact, workspace != nil {
                Menu {
                    Button(action: selectWorkspace) {
                        Label("Change Workspace", systemImage: "folder")
                    }
                } label: {
                    Label("Workspace", systemImage: "ellipsis.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderless)
            } else {
                Button(action: selectWorkspace) {
                    Label(workspace == nil ? "Select Workspace" : "Change Workspace", systemImage: "folder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(MarkFlowTheme.accent)
            }
        }
        .padding(isCompact ? 12 : 16)
        .glassPanel(cornerRadius: isCompact ? MarkFlowTheme.cardRadius : 22)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Workspace")
    }
}
