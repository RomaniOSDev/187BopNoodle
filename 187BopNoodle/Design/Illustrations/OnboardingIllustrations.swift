import SwiftUI

struct OnboardingIllustrationFrame<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppVisualStyle.surfaceGradient)
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppPrimary").opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            content()
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppVisualStyle.borderGradient(highlighted: true), lineWidth: 1.5)
        )
        .appSoftShadow(.medium)
    }
}

struct OnboardingJumpIllustration: View {
    @State private var appeared = false
    @State private var hop = false

    var body: some View {
        OnboardingIllustrationFrame {
            ZStack {
                groundLine
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color("AppTextSecondary"), Color("AppSurface")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 48, height: 22)
                    .offset(x: 58, y: 52)
                GrasshopperShape(size: 54)
                    .offset(y: hop ? -38 : 8)
            }
        }
        .scaleEffect(appeared ? 1 : 0.88)
        .opacity(appeared ? 1 : 0.2)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                hop = true
            }
        }
    }

    private var groundLine: some View {
        Capsule()
            .fill(Color("AppAccent").opacity(0.35))
            .frame(width: 160, height: 4)
            .offset(y: 68)
    }
}

struct OnboardingStarsIllustration: View {
    @State private var appeared = false
    @State private var starGlow = false

    private let starOffsets: [(x: CGFloat, y: CGFloat)] = [
        (-52, -28), (0, -42), (52, -28), (-28, 18), (28, 18)
    ]

    var body: some View {
        OnboardingIllustrationFrame {
            ZStack {
                ForEach(0..<starOffsets.count, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .font(.system(size: index == 1 ? 26 : 20))
                        .foregroundStyle(Color("AppAccent"))
                        .shadow(color: Color("AppAccent").opacity(starGlow ? 0.8 : 0.2), radius: 6)
                        .offset(x: starOffsets[index].x, y: starOffsets[index].y)
                        .scaleEffect(appeared ? 1 : 0.3)
                        .opacity(appeared ? 1 : 0)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.65)
                                .delay(Double(index) * 0.08),
                            value: appeared
                        )
                }
                GrasshopperShape(size: 48)
                    .offset(y: 44)
            }
        }
        .scaleEffect(appeared ? 1 : 0.88)
        .opacity(appeared ? 1 : 0.2)
        .onAppear {
            appeared = true
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                starGlow = true
            }
        }
    }
}

struct OnboardingAdventureIllustration: View {
    @State private var appeared = false
    @State private var pathProgress: CGFloat = 0

    var body: some View {
        OnboardingIllustrationFrame {
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 28, y: 150))
                    path.addCurve(
                        to: CGPoint(x: 200, y: 58),
                        control1: CGPoint(x: 78, y: 168),
                        control2: CGPoint(x: 148, y: 36)
                    )
                }
                .trim(from: 0, to: pathProgress)
                .stroke(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )

                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(Color("AppAccent").opacity(0.5))
                        .frame(width: 6, height: 6)
                        .offset(
                            x: CGFloat([40, 90, 140, 185][i]) - 110,
                            y: CGFloat([130, 100, 75, 55][i]) - 90
                        )
                        .opacity(pathProgress > CGFloat(i + 1) * 0.2 ? 1 : 0.2)
                }

                GrasshopperShape(size: 50)
                    .offset(x: appeared ? 52 : -48, y: appeared ? -8 : 24)
            }
        }
        .scaleEffect(appeared ? 1 : 0.88)
        .opacity(appeared ? 1 : 0.2)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 1.1)) {
                pathProgress = 1
            }
        }
    }
}
