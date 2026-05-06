//
//  WorkspaceOnboardingView.swift
//  MarkFlow Studio
//

import SwiftUI

struct WorkspaceOnboardingView: View {
    let errorMessage: String?
    let selectWorkspace: () -> Void

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    workspaceStructure
                    firstActions
                    errorSection
                    selectButton
                }
                .frame(maxWidth: 760, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
            }
        }
        .tint(MarkFlowTheme.accent)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "folder.badge.gearshape")
                .font(.system(size: 42, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(MarkFlowTheme.accent)
                .accessibilityHidden(true)

            Text("Choose your workspace")
                .font(.largeTitle.bold())

            Text("MarkFlow stores your Markdown library in a folder you control. Pick a local or iCloud Drive folder to keep documents, assets, exports, and configuration separated.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(28)
        .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
        .accessibilityElement(children: .combine)
    }

    private var workspaceStructure: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Workspace layout", systemImage: "square.stack.3d.up")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                WorkspaceFolderRow(name: "database/", description: "Local app data and document metadata")
                WorkspaceFolderRow(name: "assets/", description: "Images and files referenced from Markdown")
                WorkspaceFolderRow(name: "exports/", description: "Generated Markdown, HTML, and PDF exports")
                WorkspaceFolderRow(name: "config.json", description: "Workspace configuration written by MarkFlow")
            }
        }
        .padding(22)
        .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
    }

    private var firstActions: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("After setup", systemImage: "sparkles")
                .font(.headline)

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    OnboardingStepView(number: "1", title: "Create a folder", description: "Organize docs by topic or project.")
                    OnboardingStepView(number: "2", title: "Write Markdown", description: "Use helpers for headings, lists, links, and code.")
                    OnboardingStepView(number: "3", title: "Preview and export", description: "Review output and save to workspace exports.")
                }

                VStack(alignment: .leading, spacing: 12) {
                    OnboardingStepView(number: "1", title: "Create a folder", description: "Organize docs by topic or project.")
                    OnboardingStepView(number: "2", title: "Write Markdown", description: "Use helpers for headings, lists, links, and code.")
                    OnboardingStepView(number: "3", title: "Preview and export", description: "Review output and save to workspace exports.")
                }
            }
        }
        .padding(22)
        .glassPanel(cornerRadius: MarkFlowTheme.panelRadius)
    }

    @ViewBuilder
    private var errorSection: some View {
        if let errorMessage {
            Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                .font(.callout)
                .foregroundStyle(.red)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassPanel(cornerRadius: 18)
                .accessibilityElement(children: .combine)
        }
    }

    private var selectButton: some View {
        Button(action: selectWorkspace) {
            Label("Select Workspace Folder", systemImage: "folder")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .accessibilityHint("Opens a folder picker to initialize local MarkFlow storage.")
    }
}

private struct WorkspaceFolderRow: View {
    let name: String
    let description: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(name)
                .font(.system(.callout, design: .monospaced).weight(.semibold))
                .foregroundStyle(MarkFlowTheme.accent)
                .frame(width: 110, alignment: .leading)

            Text(description)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct OnboardingStepView: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(number)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(MarkFlowTheme.accent, in: Circle())
                .accessibilityHidden(true)

            Text(title)
                .font(.subheadline.weight(.semibold))

            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: MarkFlowTheme.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(number): \(title). \(description)")
    }
}

#Preview {
    WorkspaceOnboardingView(errorMessage: nil) { }
}
