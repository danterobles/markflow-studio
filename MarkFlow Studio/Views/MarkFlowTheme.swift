//
//  MarkFlowTheme.swift
//  MarkFlow Studio
//

import SwiftUI

enum MarkFlowTheme {
    static let accent = Color(red: 0.369, green: 0.361, blue: 0.902)
    static let cardRadius: CGFloat = 12
    static let panelRadius: CGFloat = 24
    static let editorMaxWidth: CGFloat = 800
    static let contentSpacing: CGFloat = 20
    static let cardPadding: CGFloat = 12
    static let sidebarFooterHeight: CGFloat = 82

    static var baseBackground: Color {
#if os(macOS)
        Color(nsColor: .windowBackgroundColor)
#else
        Color(.secondarySystemBackground)
#endif
    }

    static var editorFont: Font {
        .custom("JetBrains Mono", size: 16, relativeTo: .body)
    }

    static var fallbackEditorFont: Font {
        .system(size: 16, design: .monospaced)
    }
}

struct NoteCardStyle: ViewModifier {
    let isSelected: Bool
    @State private var isHovered = false
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .padding(MarkFlowTheme.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground, in: RoundedRectangle(cornerRadius: MarkFlowTheme.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: MarkFlowTheme.cardRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            }
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(isSelected ? MarkFlowTheme.accent : Color.clear)
                    .frame(width: 4)
                    .padding(.vertical, 8)
            }
            .shadow(color: .black.opacity(isHovered ? 0.10 : 0.05), radius: isHovered ? 16 : 8, y: isHovered ? 8 : 4)
            .scaleEffect(reduceMotion ? 1 : (isHovered ? 1.01 : 1))
            .animation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.86), value: isHovered)
            .animation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.86), value: isSelected)
            .onHover { isHovered = $0 }
    }

    private var cardBackground: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(MarkFlowTheme.accent.opacity(colorSchemeContrast == .increased ? 0.24 : 0.16))
        }
        return AnyShapeStyle(Color.secondary.opacity(colorSchemeContrast == .increased ? 0.12 : (isHovered ? 0.10 : 0.05)))
    }

    private var borderColor: Color {
        if isSelected {
            return MarkFlowTheme.accent.opacity(colorSchemeContrast == .increased ? 0.70 : 0.45)
        }

        return Color.primary.opacity(colorSchemeContrast == .increased ? 0.22 : (isHovered ? 0.12 : 0.06))
    }
}

struct GlassCapsuleStyle: ViewModifier {
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(capsuleBackground, in: Capsule(style: .continuous))
            .overlay {
                Capsule(style: .continuous)
                    .stroke(borderColor, lineWidth: colorSchemeContrast == .increased ? 1.5 : 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 14, y: 8)
    }

    private var capsuleBackground: AnyShapeStyle {
        if reduceTransparency {
            return AnyShapeStyle(MarkFlowTheme.baseBackground)
        }

        return AnyShapeStyle(colorSchemeContrast == .increased ? .regularMaterial : .ultraThinMaterial)
    }

    private var borderColor: Color {
        colorSchemeContrast == .increased ? Color.primary.opacity(0.22) : Color.primary.opacity(0.10)
    }
}

extension View {
    func noteCardStyle(isSelected: Bool = false) -> some View {
        modifier(NoteCardStyle(isSelected: isSelected))
    }

    func glassCapsule() -> some View {
        modifier(GlassCapsuleStyle())
    }
}
