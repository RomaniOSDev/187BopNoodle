import SwiftUI
import Combine

enum GlideObstacleKind {
  /// Leap over — collision when the grasshopper is too low while crossing.
    case overheadFlower
    /// Dash under while on the ground lane.
    case groundBush
    /// Horizontal moving leaf in the upper lane.
    case movingLeaf
}

struct GlideObstacle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let width: CGFloat
    let height: CGFloat
    let kind: GlideObstacleKind
    var speed: CGFloat
}

struct GlideStar: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var collected: Bool = false
}

final class Activity3ViewModel: ObservableObject {
    @Published var grasshopperX: CGFloat = 40
    @Published var grasshopperY: CGFloat = 300
    @Published var score = 0
    @Published var timeRemaining: Double = 90
    @Published var chargeProgress: CGFloat = 0
    @Published var isCharging = false
    @Published var obstacles: [GlideObstacle] = []
    @Published var stars: [GlideStar] = []
    @Published var gameState: GamePlayState = .playing
    @Published var showResult = false
    @Published var earnedStars = 0
    @Published var collectedCount = 0
    @Published var starsRequired = 10
    @Published var isDashing = false

    let difficulty: GameDifficulty
    let level: Int
    let activityId: String

    let worldWidth: CGFloat = 1024
    private var gameTimer: AnyCancellable?
    private var startTime = Date()
    private var screenHeight: CGFloat = 700
    private var groundY: CGFloat = 500
    private var velocityY: CGFloat = 0
    private var jumpPhysics = JumpPhysics(screenHeight: 700)

    init(activityId: String, difficulty: GameDifficulty, level: Int) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        timeRemaining = max(45, 100 - Double(level) * 4)
        generateLevel()
    }

    var leafTraversalSeconds: Double {
        switch difficulty {
        case .easy: return 3
        case .normal: return 2
        case .hard: return 1
        }
    }

    var scrollSpeed: CGFloat {
        2 + CGFloat(level) * 0.5
    }

    func configure(height: CGFloat) {
        screenHeight = height
        jumpPhysics = JumpPhysics(screenHeight: height)
        groundY = jumpPhysics.groundY
        grasshopperY = groundY
    }

    func startGame() {
        startTime = Date()
        gameTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stopGame() {
        gameTimer?.cancel()
    }

    func startCharging() {
        guard gameState == .playing else { return }
        isCharging = true
        HapticService.gameEvent()
    }

    func updateCharge() {
        guard isCharging else { return }
        chargeProgress = min(1, chargeProgress + 0.022)
    }

    func releaseCharge() {
        guard isCharging else { return }
        isCharging = false
        let minApex = screenHeight * 0.09
        let maxApex = min(screenHeight * 0.46, groundY - jumpPhysics.minY - 24)
        let apex = minApex + chargeProgress * (maxApex - minApex)
        velocityY = jumpPhysics.launchVelocity(forApexHeight: apex)
        chargeProgress = 0
        HapticService.gameEvent()
    }

    func dashRight() {
        guard gameState == .playing else { return }
        isDashing = true
        grasshopperY = groundY
        velocityY = 0
        grasshopperX += 40
        HapticService.gameEvent()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.isDashing = false
        }
    }

    private func tick() {
        guard gameState == .playing else { return }
        if isCharging { updateCharge() }

        if !isDashing {
            let step = jumpPhysics.step(y: grasshopperY, velocityY: velocityY)
            grasshopperY = step.y
            velocityY = step.velocityY
        }

        grasshopperX += scrollSpeed
        timeRemaining -= 1.0 / 60.0

        for index in obstacles.indices where obstacles[index].speed > 0 {
            obstacles[index].x -= obstacles[index].speed
            if obstacles[index].x < grasshopperX - 120 {
                obstacles[index].x = grasshopperX + worldWidth * 0.55 + CGFloat(index * 40)
            }
        }

        checkStars()
        checkCollisions()
        checkWin()

        if timeRemaining <= 0 {
            failGame()
        }
    }

    private func checkStars() {
        for index in stars.indices where !stars[index].collected {
            let star = stars[index]
            if abs(star.x - grasshopperX) < 30 && abs(star.y - grasshopperY) < 35 {
                stars[index].collected = true
                collectedCount += 1
                score += 10
                HapticService.success()
            }
        }
    }

    private func checkCollisions() {
        for obstacle in obstacles {
            guard abs(obstacle.x - grasshopperX) < obstacle.width / 2 + 20 else { continue }

            switch obstacle.kind {
            case .overheadFlower, .movingLeaf:
                if grasshopperY > obstacle.y + obstacle.height / 2 + 8 {
                    failGame()
                    return
                }
            case .groundBush:
                if !isDashing, grasshopperY > obstacle.y - 12 {
                    failGame()
                    return
                }
            }
        }
    }

    private func checkWin() {
        if grasshopperX >= worldWidth - 50 && collectedCount >= starsRequired {
            winGame()
        }
    }

    private func winGame() {
        gameState = .won
        earnedStars = StarCalculator.stars(forScore: score, thresholds: (100, 150, 200))
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
        grasshopperY = groundY
        velocityY = 0
        score = 0
        collectedCount = 0
        chargeProgress = 0
        isCharging = false
        isDashing = false
        timeRemaining = max(45, 100 - Double(level) * 4)
        gameState = .playing
        showResult = false
        generateLevel()
    }

    private func generateLevel() {
        var obs: [GlideObstacle] = []
        var st: [GlideStar] = []
        let baseSpeed = CGFloat(worldWidth / leafTraversalSeconds / 60.0)
        let fastLeafSpeed = baseSpeed * 1.35
        let slowBushSpeed = baseSpeed * 0.55
        let airborneY = groundY - screenHeight * 0.34
        let groundBushY = groundY - 18

        starsRequired = min(8 + level, 16)
        let starTotal = min(12 + level, 22)

        for i in 0..<min(6 + level, 16) {
            let spacing = CGFloat(140 + (i % 3) * 25)
            let startX = grasshopperX + 180 + CGFloat(i) * spacing

            if i % 2 == 0 {
                obs.append(GlideObstacle(
                    x: startX,
                    y: airborneY,
                    width: 44,
                    height: 28,
                    kind: .movingLeaf,
                    speed: fastLeafSpeed
                ))
            } else {
                obs.append(GlideObstacle(
                    x: startX + 60,
                    y: groundBushY,
                    width: 56,
                    height: 22,
                    kind: .groundBush,
                    speed: slowBushSpeed
                ))
            }

            if i % 3 == 0 {
                obs.append(GlideObstacle(
                    x: startX + 30,
                    y: airborneY - 20,
                    width: 36,
                    height: 32,
                    kind: .overheadFlower,
                    speed: 0
                ))
            }
        }

        for i in 0..<starTotal {
            let starLane = i % 2 == 0
                ? groundY - screenHeight * 0.22
                : groundY - screenHeight * 0.08
            st.append(GlideStar(
                x: CGFloat(120 + i * 38),
                y: starLane
            ))
        }
        obstacles = obs
        stars = st
    }
}
