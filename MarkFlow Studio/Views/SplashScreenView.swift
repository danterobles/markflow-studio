//
//  SplashScreenView.swift
//  MarkFlow Studio
//

import SwiftUI

struct RootAppView: View {
    @State private var isSplashVisible = true

    var body: some View {
        ZStack {
            ContentView()
                .opacity(isSplashVisible ? 0 : 1)

            if isSplashVisible {
                SplashScreenView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation(.smooth(duration: 0.55)) {
                isSplashVisible = false
            }
        }
    }
}

struct SplashScreenView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            background

            VStack(spacing: 28) {
                iconMark

                VStack(spacing: 8) {
                    Text("MarkFlow Writer")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Markdown that moves with your ideas")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.white.opacity(0.78))
                }
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 12)
            }
            .padding(32)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.82)) {
                hasAppeared = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("MarkFlow Writer is starting")
    }

    private var background: some View {
        ZStack {
            Image("bg_app")
                .resizable()
                .scaledToFill()
                .scaleEffect(hasAppeared && !reduceMotion ? 1.08 : 1.0)
                .offset(x: hasAppeared && !reduceMotion ? -14 : 0, y: hasAppeared && !reduceMotion ? -10 : 0)
                .animation(.easeInOut(duration: 2.5), value: hasAppeared)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.16),
                    MarkFlowTheme.accent.opacity(0.22),
                    Color.black.opacity(0.38),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(.white.opacity(0.16))
                    .frame(width: hasAppeared ? lineWidth(for: index) : 0, height: 2)
                    .rotationEffect(.degrees(index == 1 ? -8 : 8))
                    .offset(x: lineOffset(for: index).x, y: lineOffset(for: index).y)
                    .blur(radius: 0.6)
                    .animation(.smooth(duration: 1.0).delay(Double(index) * 0.14), value: hasAppeared)
            }
        }
    }

    private var iconMark: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 150, height: 150)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.34), lineWidth: 1)
                }
                .shadow(color: MarkFlowTheme.accent.opacity(0.45), radius: hasAppeared ? 34 : 8, y: hasAppeared ? 18 : 4)

            Circle()
                .stroke(.white.opacity(0.20), lineWidth: 1.2)
                .frame(width: hasAppeared ? 210 : 138, height: hasAppeared ? 210 : 138)
                .opacity(hasAppeared ? 0 : 1)
                .animation(reduceMotion ? nil : .easeOut(duration: 1.5), value: hasAppeared)

            Image("ico_app")
                .resizable()
                .scaledToFit()
                .frame(width: 92, height: 92)
                .scaleEffect(hasAppeared ? 1 : 0.82)
                .rotationEffect(.degrees(hasAppeared && !reduceMotion ? 0 : -8))
        }
        .opacity(hasAppeared ? 1 : 0)
        .scaleEffect(hasAppeared ? 1 : 0.86)
    }

    private func lineWidth(for index: Int) -> CGFloat {
        [120, 170, 96][index]
    }

    private func lineOffset(for index: Int) -> CGPoint {
        [
            CGPoint(x: -120, y: -145),
            CGPoint(x: 132, y: 150),
            CGPoint(x: 118, y: -110),
        ][index]
    }
}

#Preview {
    SplashScreenView()
}
