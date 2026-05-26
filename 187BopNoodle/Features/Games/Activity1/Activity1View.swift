import SwiftUI

struct Activity1View: View {
    @EnvironmentObject private var storage: GameStorage
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: Activity1ViewModel
    @State private var groundY: CGFloat = 500
    @State private var didRecordSession = false

    let activityId: String
    let difficulty: GameDifficulty
    let level: Int

    init(activityId: String, difficulty: GameDifficulty, level: Int) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        _viewModel = StateObject(wrappedValue: Activity1ViewModel(
            activityId: activityId,
            difficulty: difficulty,
            level: level,
            groundY: 500
        ))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                GameMeadowBackground()
                gameLayer(size: geo.size)
                hud
                if viewModel.showResult {
                    resultOverlay
                        .onAppear { saveProgressIfNeeded() }
                }
            }
            .onAppear {
                groundY = geo.size.height * 0.75
                viewModel.configure(size: geo.size)
                viewModel.startGame()
            }
            .onDisappear {
                viewModel.stopGame()
            }
            .gesture(
                TapGesture(count: 1).onEnded {
                    viewModel.handleTap()
                }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if abs(value.translation.width) > abs(value.translation.height) {
                            viewModel.handleSwipe()
                        }
                    }
            )
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func gameLayer(size: CGSize) -> some View {
        let ground = viewModel.groundY
        ZStack {
            Rectangle()
                .fill(Color("AppSurface").opacity(0.85))
                .frame(width: size.width * 3, height: 14)
                .position(x: size.width / 2, y: ground + 6)

            ForEach(viewModel.obstacles) { obstacle in
                obstacleView(obstacle, ground: ground)
            }
            ForEach(viewModel.collectibles) { star in
                if !star.collected {
                    CollectibleStarShape()
                        .position(
                            x: star.x - viewModel.scrollOffset,
                            y: star.y
                        )
                }
            }
            GrasshopperShape(size: 44)
                .position(
                    x: viewModel.grasshopperScreenX,
                    y: viewModel.grasshopperY
                )
                .offset(y: viewModel.isDashing ? 32 : 0)
        }
    }

    @ViewBuilder
    private func obstacleView(_ obstacle: GameObstacle, ground: CGFloat) -> some View {
        let x = obstacle.x - viewModel.scrollOffset
        switch obstacle.kind {
        case .rock(let height):
            RoundedRectangle(cornerRadius: 4)
                .fill(Color("AppTextSecondary"))
                .frame(width: 44, height: height)
                .position(x: x, y: ground - height / 2)
        case .log(let height):
            RoundedRectangle(cornerRadius: 6)
                .fill(Color("AppSurface"))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color("AppTextSecondary").opacity(0.5), lineWidth: 2)
                )
                .frame(width: 64, height: height)
                .position(x: x, y: ground - height / 2)
        case .leaf(let yPos):
            Ellipse()
                .fill(Color("AppAccent").opacity(0.8))
                .frame(width: 90, height: 28)
                .position(x: x, y: yPos)
        }
    }

    private var hud: some View {
        VStack {
            GameHudBar(
                onClose: {
                    HapticService.buttonTap()
                    viewModel.stopGame()
                    dismiss()
                },
                leadingTitle: "Leap Sprint",
                trailingItems: [
                    ("Score", "\(viewModel.score)"),
                    ("Stars", "\(viewModel.collectedStarsCount)/\(viewModel.totalStarsTarget)"),
                    ("Jumps", "\(viewModel.jumpsRemaining)")
                ]
            )
            Spacer()
            Text("Tap jump • Tap in air • Double-tap high • Swipe dash")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppVisualStyle.surfaceGradient)
                .overlay(Capsule().stroke(Color("AppPrimary").opacity(0.25), lineWidth: 1))
                .clipShape(Capsule())
                .appSoftShadow(.low)
                .padding(.bottom, 10)
        }
    }

    private var resultOverlay: some View {
        GameResultView(config: resultConfig)
    }

    private var resultConfig: GameResultConfig {
        let success = viewModel.gameState == .won
        let hasNext = level < ActivityInfo.levelsPerDifficulty - 1
        return GameResultConfig(
            isSuccess: success,
            starsEarned: viewModel.earnedStars,
            primaryMetric: "\(viewModel.score)",
            metricLabel: "Score",
            showNextLevel: success && hasNext,
            newAchievement: success ? AchievementChecker.newlyUnlocked(in: storage) : nil,
            onRetry: { retryLevel() },
            onBackToLevels: { finishAndDismiss() },
            onNextLevel: success && hasNext ? { advanceLevel() } : nil
        )
    }

    private func retryLevel() {
        didRecordSession = false
        viewModel.resetLevel()
        viewModel.startGame()
    }

    private func advanceLevel() {
        finishSession()
        dismiss()
    }

    private func finishAndDismiss() {
        finishSession()
        dismiss()
    }

    private func saveProgressIfNeeded() {
        guard !didRecordSession else { return }
        didRecordSession = true
        if viewModel.gameState == .won {
            storage.saveStars(
                viewModel.earnedStars,
                activityId: activityId,
                difficulty: difficulty,
                level: level
            )
        }
        storage.recordPlaySession(durationSeconds: viewModel.playDuration())
    }

    private func finishSession() {
        saveProgressIfNeeded()
        viewModel.stopGame()
    }
}
