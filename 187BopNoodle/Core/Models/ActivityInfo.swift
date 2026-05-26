import Foundation

struct ActivityInfo: Identifiable {
    static let levelsPerDifficulty = 12

    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let levelsPerDifficulty: Int

    var lastLevelIndex: Int { levelsPerDifficulty - 1 }

    static let all: [ActivityInfo] = [
        ActivityInfo(
            id: "grasshopper_leap_sprint",
            title: "Grasshopper Leap Sprint",
            subtitle: "Tap to leap, swipe to dash under leaves",
            iconName: "hare.fill",
            levelsPerDifficulty: ActivityInfo.levelsPerDifficulty
        ),
        ActivityInfo(
            id: "meadow_leap_challenge",
            title: "Meadow Leap Challenge",
            subtitle: "Drag to guide your path through the meadow",
            iconName: "leaf.fill",
            levelsPerDifficulty: ActivityInfo.levelsPerDifficulty
        ),
        ActivityInfo(
            id: "grasshopper_leap_glide",
            title: "Grasshopper Leap Glide",
            subtitle: "Charge leaps and dash to the finish",
            iconName: "wind",
            levelsPerDifficulty: ActivityInfo.levelsPerDifficulty
        )
    ]

    static func find(id: String) -> ActivityInfo? {
        all.first { $0.id == id }
    }
}
