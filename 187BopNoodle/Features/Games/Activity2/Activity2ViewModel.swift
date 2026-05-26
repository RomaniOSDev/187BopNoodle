import SwiftUI
import Combine

struct MeadowObstacle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let width: CGFloat
    let height: CGFloat
}

struct MeadowStar: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var collected: Bool = false
}

final class Activity2ViewModel: ObservableObject {
    @Published var grasshopperX: CGFloat = 40
    @Published var grasshopperY: CGFloat = 40
    @Published var score = 0
    @Published var timeRemaining: Double = 60
    @Published var collisionCount = 0
    @Published var obstacles: [MeadowObstacle] = []
    @Published var stars: [MeadowStar] = []
    @Published var finishX: CGFloat = 350
    @Published var gameState: GamePlayState = .playing
    @Published var showResult = false
    @Published var earnedStars = 0

    let difficulty: GameDifficulty
    let level: Int
    let activityId: String

    private var gameTimer: AnyCancellable?
    private var startTime = Date()
    private var screenSize: CGSize = CGSize(width: 375, height: 667)
    private var dragStartX: CGFloat = 0
    private var dragStartY: CGFloat = 0
    private var isDragging = false

    /// Finger-to-world scale (lower = less sensitive).
    private let dragSensitivity: CGFloat = 0.42

    init(activityId: String, difficulty: GameDifficulty, level: Int) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        timeRemaining = max(30, 75 - Double(level) * 3)
        generateLevel()
    }

    var safeBuffer: CGFloat {
        switch difficulty {
        case .easy: return 30
        case .normal: return 15
        case .hard: return 5
        }
    }

    func configure(size: CGSize) {
        screenSize = size
        finishX = size.width - 40
        grasshopperY = size.height * 0.75
    }

    func startGame() {
        startTime = Date()
        gameTimer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stopGame() {
        gameTimer?.cancel()
    }

    func beginDrag() {
        guard gameState == .playing else { return }
        isDragging = true
        dragStartX = grasshopperX
        dragStartY = grasshopperY
    }

    func handleDrag(translation: CGSize) {
        guard gameState == .playing, isDragging else { return }

        let topBound = screenSize.height * 0.16
        let bottomBound = screenSize.height * 0.75
        grasshopperX = min(
            max(20, dragStartX + translation.width * dragSensitivity),
            screenSize.width - 40
        )
        grasshopperY = min(
            max(topBound, dragStartY - translation.height * dragSensitivity),
            bottomBound
        )
        checkInteractions()
    }

    func endDrag() {
        isDragging = false
        HapticService.buttonTap()
    }

    private func tick() {
        guard gameState == .playing else { return }
        timeRemaining -= 1.0 / 30.0
        if timeRemaining <= 0 {
            failGame()
        }
        if grasshopperX >= finishX {
            winGame()
        }
    }

    private func checkInteractions() {
        for star in stars where !star.collected {
            if distance(grasshopperX, grasshopperY, star.x, star.y) < 35 {
                if let idx = stars.firstIndex(where: { $0.id == star.id }) {
                    stars[idx].collected = true
                    score += 10
                    HapticService.success()
                }
            }
        }

        for obstacle in obstacles {
            let expanded = safeBuffer
            if grasshopperX + expanded > obstacle.x - obstacle.width / 2 &&
                grasshopperX - expanded < obstacle.x + obstacle.width / 2 &&
                grasshopperY + expanded > obstacle.y - obstacle.height / 2 &&
                grasshopperY - expanded < obstacle.y + obstacle.height / 2 {
                collisionCount += 1
                HapticService.screenShake()
                if collisionCount >= 3 {
                    failGame()
                }
            }
        }
    }

    private func distance(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) -> CGFloat {
        hypot(x1 - x2, y1 - y2)
    }

    private func winGame() {
        gameState = .won
        earnedStars = StarCalculator.stars(forScore: score, thresholds: (10, 20, 30))
        stopGame()
        showResult = true
        SoundService.playSuccess()
    }

    private func failGame() {
        gameState = .lost
        earnedStars = 0
        stopGame()
        showResult = true
        HapticService.error()
        SoundService.playFail()
    }

    func playDuration() -> Int {
        Int(Date().timeIntervalSince(startTime))
    }

    func resetLevel() {
        grasshopperX = 40
        grasshopperY = screenSize.height * 0.75
        isDragging = false
        score = 0
        collisionCount = 0
        timeRemaining = max(30, 75 - Double(level) * 3)
        gameState = .playing
        showResult = false
        generateLevel()
    }

    private func generateLevel() {
        var obs: [MeadowObstacle] = []
        var st: [MeadowStar] = []
        for i in 0..<min(5 + level, 14) {
            let x = CGFloat(80 + i * 45)
            let y = CGFloat(120 + (i % 4) * 80)
            obs.append(MeadowObstacle(x: x, y: y, width: 30, height: 50))
            st.append(MeadowStar(
                x: CGFloat.random(in: 50...300),
                y: CGFloat.random(in: 100...400)
            ))
        }
        obstacles = obs
        stars = st
    }
}
