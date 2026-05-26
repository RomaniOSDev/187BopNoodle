import SwiftUI

struct Activity2View: View {
    @EnvironmentObject private var storage: GameStorage
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: Activity2ViewModel
    @State private var didRecordSession = false
    @State private var isDragging = false

    let activityId: String
    let difficulty: GameDifficulty
    let level: Int

    init(activityId: String, difficulty: GameDifficulty, level: Int) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        _viewModel = StateObject(wrappedValue: Activity2ViewModel(
            activityId: activityId,
            difficulty: difficulty,
            level: level
        ))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                GameMeadowBackground()
                gameContent(size: geo.size)
                hud
                if viewModel.showResult {
                    resultOverlay
                        .onAppear { saveProgressIfNeeded() }
                }
            }
            .onAppear {
                viewModel.configure(size: geo.size)
                viewModel.startGame()
            }
            .onDisappear { viewModel.stopGame() }
            .gesture(
                DragGesture(minimumDistance: 12)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            viewModel.beginDrag()
                        }
                        viewModel.handleDrag(translation: value.translation)
                    }
                    .onEnded { _ in
                        isDragging = false
                        viewModel.endDrag()
                    }
            )
        }
        .navigationBarHidden(true)
    }

    private func gameContent(size: CGSize) -> some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 20, y: size.height - 80))
                path.addLine(to: CGPoint(x: size.width - 20, y: size.height - 120))
            }
            .stroke(Color("AppAccent").opacity(0.5), lineWidth: 3)

            ForEach(viewModel.obstacles) { obs in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("AppSurface"))
                    .frame(width: obs.width, height: obs.height)
                    .position(x: obs.x, y: obs.y)
            }

            ForEach(viewModel.stars) { star in
                if !star.collected {
                    CollectibleStarShape(size: 20)
                        .position(x: star.x, y: star.y)
                }
            }

            RoundedRectangle(cornerRadius: 4)
                .stroke(Color("AppPrimary"), lineWidth: 2)
                .frame(width: 30, height: 8)
                .position(x: viewModel.finishX, y: size.height - 100)

            GrasshopperShape(size: 36)
                .position(x: viewModel.grasshopperX, y: viewModel.grasshopperY)
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
                leadingTitle: "Meadow Challenge",
                trailingItems: [
                    ("Score", "\(viewModel.score)"),
                    ("Time", String(format: "%.0f", viewModel.timeRemaining)),
                    ("Hits", "\(viewModel.collisionCount)/3")
                ]
            )
            Spacer()
            Text("Drag to move • Reach the finish line")
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
