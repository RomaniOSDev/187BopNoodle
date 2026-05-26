import SwiftUI

struct Activity3View: View {
    @EnvironmentObject private var storage: GameStorage
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: Activity3ViewModel
    @State private var didRecordSession = false

    let activityId: String
    let difficulty: GameDifficulty
    let level: Int

    init(activityId: String, difficulty: GameDifficulty, level: Int) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        _viewModel = StateObject(wrappedValue: Activity3ViewModel(
            activityId: activityId,
            difficulty: difficulty,
            level: level
        ))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                GameMeadowBackground()
                TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { _ in
                    gameContent(size: geo.size)
                }
                hud
                chargeIndicator
                if viewModel.showResult {
                    resultOverlay
                        .onAppear { saveProgressIfNeeded() }
                }
            }
            .onAppear {
                viewModel.configure(height: geo.size.height)
                viewModel.startGame()
            }
            .onDisappear { viewModel.stopGame() }
            .gesture(longPressGesture)
            .simultaneousGesture(swipeGesture)
        }
        .navigationBarHidden(true)
    }

    private var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.2)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                switch value {
                case .first(true):
                    viewModel.startCharging()
                default:
                    break
                }
            }
            .onEnded { _ in
                viewModel.releaseCharge()
            }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 40)
            .onEnded { value in
                if value.translation.width > 50 && abs(value.translation.height) < 40 {
                    viewModel.dashRight()
                }
            }
    }

    @ViewBuilder
    private func gameContent(size: CGSize) -> some View {
        let cameraX = viewModel.grasshopperX
        ZStack {
            Canvas { context, canvasSize in
                for i in 0..<10 {
                    let rect = CGRect(x: CGFloat(i) * 40 - cameraX.truncatingRemainder(dividingBy: 40), y: canvasSize.height - 60, width: 30, height: 50)
                    context.fill(Path(roundedRect: rect, cornerRadius: 4), with: .color(Color("AppSurface").opacity(0.5)))
                }
            }

            ForEach(viewModel.obstacles) { obs in
                obstacleShape(obs)
                    .position(x: obs.x - cameraX + size.width * 0.3, y: obs.y)
            }

            ForEach(viewModel.stars) { star in
                if !star.collected {
                    CollectibleStarShape(size: 18)
                        .position(
                            x: star.x - cameraX + size.width * 0.3,
                            y: star.y
                        )
                }
            }

            GrasshopperShape(size: 40)
                .position(x: size.width * 0.3, y: viewModel.grasshopperY)
                .offset(y: viewModel.isDashing ? 28 : 0)
        }
    }

    @ViewBuilder
    private func obstacleShape(_ obs: GlideObstacle) -> some View {
        switch obs.kind {
        case .overheadFlower, .movingLeaf:
            Circle()
                .fill(Color("AppAccent").opacity(0.75))
                .frame(width: obs.width, height: obs.height)
        case .groundBush:
            RoundedRectangle(cornerRadius: 4)
                .fill(Color("AppTextSecondary"))
                .frame(width: obs.width, height: obs.height)
        }
    }

    private var chargeIndicator: some View {
        VStack {
            Spacer()
            if viewModel.isCharging {
                ProgressView(value: viewModel.chargeProgress)
                    .tint(Color("AppAccent"))
                    .padding(.horizontal, 40)
                    .padding(.bottom, 100)
            }
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
                leadingTitle: "Leap Glide",
                trailingItems: [
                    ("Score", "\(viewModel.score)"),
                    ("Stars", "\(viewModel.collectedCount)/\(viewModel.starsRequired)"),
                    ("Time", String(format: "%.0f", viewModel.timeRemaining))
                ]
            )
            Spacer()
            Text("Hold leap over flowers • Swipe under bushes")
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
        GameResultView(config: GameResultConfig(
            isSuccess: viewModel.gameState == .won,
            starsEarned: viewModel.earnedStars,
            primaryMetric: "\(viewModel.score)",
            metricLabel: "Score",
            showNextLevel: viewModel.gameState == .won && level < ActivityInfo.levelsPerDifficulty - 1,
            newAchievement: viewModel.gameState == .won ? AchievementChecker.newlyUnlocked(in: storage) : nil,
            onRetry: {
                didRecordSession = false
                viewModel.resetLevel()
                viewModel.startGame()
            },
            onBackToLevels: {
                finishSession()
                dismiss()
            },
            onNextLevel: viewModel.gameState == .won && level < ActivityInfo.levelsPerDifficulty - 1 ? {
                finishSession()
                dismiss()
            } : nil
        ))
    }

    private func saveProgressIfNeeded() {
        guard !didRecordSession else { return }
        didRecordSession = true
        if viewModel.gameState == .won {
            storage.saveStars(viewModel.earnedStars, activityId: activityId, difficulty: difficulty, level: level)
        }
        storage.recordPlaySession(durationSeconds: viewModel.playDuration())
    }

    private func finishSession() {
        saveProgressIfNeeded()
        viewModel.stopGame()
    }
}
