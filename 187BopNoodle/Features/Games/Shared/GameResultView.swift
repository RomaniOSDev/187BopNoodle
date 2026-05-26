import SwiftUI

struct GameResultConfig {
    let isSuccess: Bool
    let starsEarned: Int
    let primaryMetric: String
    let metricLabel: String
    let showNextLevel: Bool
    let newAchievement: AchievementDefinition?
    let onRetry: () -> Void
    let onBackToLevels: () -> Void
    let onNextLevel: (() -> Void)?
}

struct GameResultView: View {
    let config: GameResultConfig
    @State private var showRedFlash = false
    @State private var showAchievementBanner = false
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color("AppBackground").opacity(0.92)
                .ignoresSafeArea()

            if showRedFlash {
                Color.red.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            ScrollView {
                SurfaceCard(highlighted: config.isSuccess) {
                    VStack(spacing: 22) {
                        resultHeader
                        scoreBlock

                        if showAchievementBanner, let achievement = config.newAchievement {
                            achievementBanner(achievement)
                        }

                        actionButtons
                    }
                    .padding(20)
                }
                .padding(20)
            }
            .offset(x: shakeOffset)
        }
        .onAppear { handleAppear() }
    }

    @ViewBuilder
    private var resultHeader: some View {
        if config.isSuccess {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color("AppAccent"))
                Text("Level Complete!")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                AnimatedResultStarsView(count: config.starsEarned)
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.red.opacity(0.9))
                Text("Try Again")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        Image(systemName: "star")
                            .font(.system(size: 32))
                            .foregroundStyle(Color("AppTextSecondary").opacity(0.3))
                    }
                }
            }
        }
    }

    private var scoreBlock: some View {
        VStack(spacing: 4) {
            Text(config.metricLabel.uppercased())
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextSecondary"))
            Text(config.primaryMetric)
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(Color("AppAccent"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppBackground").opacity(0.7),
                            Color("AppPrimary").opacity(0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color("AppAccent").opacity(0.35), lineWidth: 1)
        )
    }

    private func achievementBanner(_ achievement: AchievementDefinition) -> some View {
        HStack(spacing: 10) {
            Image(systemName: achievement.iconName)
                .foregroundStyle(Color("AppAccent"))
            Text("Achievement: \(achievement.title)")
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("AppPrimary").opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if config.isSuccess, config.showNextLevel, let next = config.onNextLevel {
                AppButton(title: "Next Level", action: next)
            }
            AppButton(
                title: config.isSuccess ? "Retry" : "Try Again",
                style: config.isSuccess ? .secondary : .primary,
                action: config.onRetry
            )
            AppButton(title: "Back to Levels", style: .secondary, action: config.onBackToLevels)
        }
    }

    private func handleAppear() {
        if config.isSuccess {
            HapticService.success()
            SoundService.playSuccess()
            if config.newAchievement != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) { showAchievementBanner = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { showAchievementBanner = false }
                    }
                }
            }
        } else {
            HapticService.error()
            SoundService.playFail()
            triggerRedFlash()
            triggerShake()
        }
    }

    private func triggerRedFlash() {
        withAnimation(.easeInOut(duration: 0.15)) { showRedFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.15)) { showRedFlash = false }
        }
    }

    private func triggerShake() {
        HapticService.screenShake()
        let offsets: [CGFloat] = [8, -8, 6, -6, 0]
        for (index, offset) in offsets.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                withAnimation(.easeInOut(duration: 0.05)) { shakeOffset = offset }
            }
        }
    }
}

enum StarCalculator {
    static func stars(forScore score: Int, thresholds: (one: Int, two: Int, three: Int)) -> Int {
        if score >= thresholds.three { return 3 }
        if score >= thresholds.two { return 2 }
        if score >= thresholds.one { return 1 }
        return 0
    }
}

enum AchievementChecker {
    static func newlyUnlocked(in storage: GameStorage) -> AchievementDefinition? {
        AchievementDefinition.all.first { $0.isUnlocked(storage) }
    }
}
