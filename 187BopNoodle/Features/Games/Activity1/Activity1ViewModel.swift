import SwiftUI
import Combine

enum ObstacleKind {
    case rock(height: CGFloat)
    case log(height: CGFloat)
    case leaf(yPosition: CGFloat)
}

struct GameObstacle: Identifiable {
    let id = UUID()
    var x: CGFloat
    let kind: ObstacleKind
    var passed: Bool = false
}

struct GameCollectible: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var collected: Bool = false
}

final class Activity1ViewModel: ObservableObject {
    @Published var grasshopperY: CGFloat = 0
    @Published var isDashing = false
    @Published var scrollOffset: CGFloat = 0
    @Published var score = 0
    @Published var obstacles: [GameObstacle] = []
    @Published var collectibles: [GameCollectible] = []
    @Published var gameState: GamePlayState = .playing
    private(set) var groundLevel: CGFloat = 500
    @Published var showResult = false
    @Published var earnedStars = 0
    @Published var totalStarsTarget = 0
    @Published var collectedStarsCount = 0
    @Published var jumpsRemaining = 2

    let difficulty: GameDifficulty
    let level: Int
    let activityId: String
    var groundY: CGFloat

    private var velocityY: CGFloat = 0
    private var jumpPhysics = JumpPhysics(screenHeight: 700)
    private var lastTapTime: Date?
    private let maxJumps = 2
    private let hopperClearance: CGFloat = 10
    private let dashDuckOffset: CGFloat = 32
    private var gameTimer: AnyCancellable?
    private var startTime = Date()
    private var screenWidth: CGFloat = 400
    private var screenHeight: CGFloat = 700
    private let grasshopperXRatio: CGFloat = 0.25

    init(activityId: String, difficulty: GameDifficulty, level: Int, groundY: CGFloat) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        self.groundY = groundY
        generateLevel()
    }

    var grasshopperScreenX: CGFloat { screenWidth * grasshopperXRatio }

    func configure(size: CGSize) {
        screenWidth = size.width
        screenHeight = size.height
        jumpPhysics = JumpPhysics(
            screenHeight: size.height,
            normalApexRatio: 0.16,
            highApexRatio: 0.30,
            airApexRatio: 0.13
        )
        groundLevel = jumpPhysics.groundY
        groundY = groundLevel
        grasshopperY = groundLevel
        jumpsRemaining = maxJumps
        generateLevel()
    }

    private var isOnGround: Bool {
        grasshopperY >= groundY - 3
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
        gameTimer = nil
    }

    func handleTap() {
        guard gameState == .playing else { return }
        HapticService.gameEvent()
        let now = Date()
        let isDoubleTap = lastTapTime.map { now.timeIntervalSince($0) < 0.35 } ?? false
        lastTapTime = now

        if isDoubleTap, isOnGround {
            velocityY = jumpPhysics.highJumpVelocity(screenHeight: screenHeight)
            jumpsRemaining = 0
            return
        }

        guard jumpsRemaining > 0 else { return }

        if isOnGround {
            velocityY = jumpPhysics.normalJumpVelocity(screenHeight: screenHeight)
        } else {
            let airVelocity = jumpPhysics.airJumpVelocity(screenHeight: screenHeight)
            velocityY = min(velocityY, airVelocity)
        }
        jumpsRemaining -= 1
    }

    func handleSwipe() {
        guard gameState == .playing else { return }
        HapticService.gameEvent()
        isDashing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isDashing = false
        }
    }

    private func tick() {
        guard gameState == .playing else { return }

        let speed: CGFloat = 3 + CGFloat(level) * 0.3
        scrollOffset += speed

        let step = jumpPhysics.step(y: grasshopperY, velocityY: velocityY)
        grasshopperY = step.y
        velocityY = step.velocityY
        if step.onGround {
            jumpsRemaining = maxJumps
        }

        checkCollisions()
        checkCollectibles()
        checkWinCondition()
    }

    private var hitboxY: CGFloat {
        isDashing ? grasshopperY + dashDuckOffset : grasshopperY
    }

    private func checkCollisions() {
        for index in obstacles.indices {
            let obs = obstacles[index]
            let obsScreenX = obs.x - scrollOffset

            if obsScreenX < grasshopperScreenX - 45 {
                obstacles[index].passed = true
                continue
            }

            guard abs(obsScreenX - grasshopperScreenX) < 42 else { continue }
            if obs.passed { continue }

            switch obs.kind {
            case .rock(let height), .log(let height):
                let obstacleTop = groundY - height
                if isClearedOver(obstacleTop: obstacleTop) {
                    obstacles[index].passed = true
                } else if !isDashing {
                    failGame()
                }
            case .leaf(let yPos):
                if isDashing {
                    obstacles[index].passed = true
                } else if isHittingOverheadLeaf(at: yPos) {
                    failGame()
                }
            }
        }
    }

    private func isClearedOver(obstacleTop: CGFloat) -> Bool {
        hitboxY <= obstacleTop - hopperClearance
    }

    private func isHittingOverheadLeaf(at yPos: CGFloat) -> Bool {
        hitboxY > yPos - 24 && hitboxY < yPos + 40
    }

    private func checkCollectibles() {
        for index in collectibles.indices where !collectibles[index].collected {
            let star = collectibles[index]
            let screenX = star.x - scrollOffset
            if abs(screenX - grasshopperScreenX) < 40 &&
                abs(star.y - grasshopperY) < 40 {
                collectibles[index].collected = true
                collectedStarsCount += 1
                score += 10
                HapticService.success()
            }
        }
    }

    private func checkWinCondition() {
        let reachedEnd = scrollOffset > levelEndDistance
        guard reachedEnd else { return }

        let allCollected = collectibles.allSatisfy(\.collected)
        if allCollected {
            winGame()
        } else if collectedStarsCount >= max(1, totalStarsTarget - 1) {
            winGame()
        } else {
            failGame()
        }
    }

    private var levelEndDistance: CGFloat {
        levelSpacing * CGFloat(obstacles.count + 2)
    }

    private func winGame() {
        gameState = .won
        earnedStars = StarCalculator.stars(
            forScore: score,
            thresholds: (10, 20, 30)
        )
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

    private var levelSpacing: CGFloat = 300

    private func spacingForDifficulty() -> CGFloat {
        switch difficulty {
        case .easy: return 300
        case .normal: return 250
        case .hard: return CGFloat.random(in: 150...200)
        }
    }

    func resetLevel() {
        scrollOffset = 0
        grasshopperY = groundY
        velocityY = 0
        jumpsRemaining = maxJumps
        gameState = .playing
        score = 0
        collectedStarsCount = 0
        showResult = false
        generateLevel()
    }

    private func generateLevel() {
        levelSpacing = spacingForDifficulty()
        var x: CGFloat = 400
        var obs: [GameObstacle] = []
        var stars: [GameCollectible] = []
        let count = min(4 + level, 14)

        let rockHeight: CGFloat = 44
        let logHeight: CGFloat = 88

        for i in 0..<count {
            if i % 3 == 2 {
                let leafY = groundY - CGFloat.random(in: 110...170)
                obs.append(GameObstacle(x: x, kind: .leaf(yPosition: leafY)))
            } else if i % 2 == 0 {
                obs.append(GameObstacle(x: x, kind: .rock(height: rockHeight)))
            } else {
                obs.append(GameObstacle(x: x, kind: .log(height: logHeight)))
            }
            let starHeight = i % 2 == 0
                ? screenHeight * 0.12
                : screenHeight * 0.22
            stars.append(GameCollectible(
                x: x + levelSpacing * 0.45,
                y: groundY - starHeight
            ))
            x += levelSpacing
        }
        obstacles = obs
        collectibles = stars
        totalStarsTarget = stars.count
    }
}
