import CoreGraphics

/// Discrete vertical physics tuned for 60 FPS (velocity & gravity in points per frame).
struct JumpPhysics {
    let groundY: CGFloat
    let minY: CGFloat
    let gravity: CGFloat

    let normalApexRatio: CGFloat
    let highApexRatio: CGFloat
    let airApexRatio: CGFloat

    init(
        screenHeight: CGFloat,
        normalApexRatio: CGFloat = 0.15,
        highApexRatio: CGFloat = 0.28,
        airApexRatio: CGFloat = 0.12
    ) {
        groundY = screenHeight * 0.75
        minY = screenHeight * 0.16
        gravity = screenHeight * 0.00095
        self.normalApexRatio = normalApexRatio
        self.highApexRatio = highApexRatio
        self.airApexRatio = airApexRatio
    }

    /// Initial upward velocity (negative Y) for a target apex height above ground.
    func launchVelocity(forApexHeight apex: CGFloat) -> CGFloat {
        let clampedApex = min(max(apex, 24), groundY - minY - 8)
        return -sqrt(2 * gravity * clampedApex)
    }

    func normalJumpVelocity(screenHeight: CGFloat) -> CGFloat {
        launchVelocity(forApexHeight: screenHeight * normalApexRatio)
    }

    func highJumpVelocity(screenHeight: CGFloat) -> CGFloat {
        launchVelocity(forApexHeight: screenHeight * highApexRatio)
    }

    func airJumpVelocity(screenHeight: CGFloat) -> CGFloat {
        launchVelocity(forApexHeight: screenHeight * airApexRatio)
    }

    /// Integrate one frame; returns new Y and velocity.
    func step(y: CGFloat, velocityY: CGFloat) -> (y: CGFloat, velocityY: CGFloat, onGround: Bool) {
        var vy = velocityY + gravity
        var newY = y + vy

        if newY >= groundY {
            newY = groundY
            vy = 0
            return (newY, vy, true)
        }

        if newY <= minY {
            newY = minY
            vy = 0
        }

        return (newY, vy, false)
    }
}
