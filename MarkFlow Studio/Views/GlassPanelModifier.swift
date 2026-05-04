//
//  GlassPanelModifier.swift
//  MarkFlow Studio
//

import SwiftUI

struct GlassPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = MarkFlowTheme.panelRadius

    func body(content: Content) -> some View {
        content
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.20), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 20, y: 12)
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat = MarkFlowTheme.panelRadius) -> some View {
        modifier(GlassPanelModifier(cornerRadius: cornerRadius))
    }
}
