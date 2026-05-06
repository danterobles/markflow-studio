//
//  GlassPanelModifier.swift
//  MarkFlow Studio
//

import SwiftUI

struct GlassPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = MarkFlowTheme.panelRadius
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        content
            .background(panelBackground, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: colorSchemeContrast == .increased ? 1.5 : 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 20, y: 12)
    }

    private var panelBackground: AnyShapeStyle {
        if reduceTransparency {
            return AnyShapeStyle(MarkFlowTheme.baseBackground)
        }

        return AnyShapeStyle(colorSchemeContrast == .increased ? .regularMaterial : .thinMaterial)
    }

    private var borderColor: Color {
        colorSchemeContrast == .increased ? Color.primary.opacity(0.22) : Color.primary.opacity(0.10)
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat = MarkFlowTheme.panelRadius) -> some View {
        modifier(GlassPanelModifier(cornerRadius: cornerRadius))
    }
}
