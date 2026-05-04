//
//  AppBackgroundView.swift
//  MarkFlow Studio
//

import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            MarkFlowTheme.baseBackground

            LinearGradient(
                colors: [
                    MarkFlowTheme.accent.opacity(0.14),
                    Color.purple.opacity(0.08),
                    Color.clear,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(MarkFlowTheme.accent.opacity(0.12))
                .blur(radius: 70)
                .frame(width: 280, height: 280)
                .offset(x: -130, y: -180)

            Circle()
                .fill(Color.cyan.opacity(0.08))
                .blur(radius: 80)
                .frame(width: 320, height: 320)
                .offset(x: 170, y: 260)
        }
        .ignoresSafeArea()
    }
}
