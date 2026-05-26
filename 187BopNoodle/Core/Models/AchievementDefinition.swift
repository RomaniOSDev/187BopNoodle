import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let isUnlocked: (GameStorage) -> Bool

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_star",
            title: "First Star",
            description: "Collected your first star.",
            iconName: "star.fill"
        ) { $0.totalStarsEarned >= 1 },
        AchievementDefinition(
            id: "rookie_jumper",
            title: "Rookie Jumper",
            description: "Played 10 activities.",
            iconName: "figure.run"
        ) { $0.totalActivitiesPlayed >= 10 },
        AchievementDefinition(
            id: "leap_master",
            title: "Leap Master",
            description: "Jumped flawlessly in one activity.",
            iconName: "bolt.fill"
        ) { $0.hasPerfectThreeStarRun },
        AchievementDefinition(
            id: "plus_500_seconds",
            title: "+500 Seconds",
            description: "+500 seconds of play time.",
            iconName: "clock.fill"
        ) { $0.totalPlayTimeSeconds >= 500 },
        AchievementDefinition(
            id: "star_collector",
            title: "Star Collector",
            description: "Earned a total of 50 stars.",
            iconName: "sparkles"
        ) { $0.totalStarsEarned >= 50 },
        AchievementDefinition(
            id: "level_unlocker",
            title: "Level Unlocker",
            description: "Unlocked new levels.",
            iconName: "lock.open.fill"
        ) { $0.totalUnlockedLevelSlots > 1 },
        AchievementDefinition(
            id: "consistent_play",
            title: "Consistent Play",
            description: "Played daily for one week.",
            iconName: "calendar"
        ) { $0.streakCount >= 7 },
        AchievementDefinition(
            id: "onboarding_pro",
            title: "Onboarding Pro",
            description: "Completed onboarding.",
            iconName: "checkmark.seal.fill"
        ) { $0.hasSeenOnboarding }
    ]
}
