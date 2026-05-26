import SwiftUI

struct ActivityCardCell: View {
    @EnvironmentObject private var storage: GameStorage
    let activity: ActivityInfo

    private var completedLevels: Int {
        var count = 0
        for difficulty in GameDifficulty.allCases {
            for level in 0..<activity.levelsPerDifficulty {
                if storage.stars(for: activity.id, difficulty: difficulty, level: level) > 0 {
                    count += 1
                }
            }
        }
        return count
    }

    private var totalLevels: Int {
        activity.levelsPerDifficulty * GameDifficulty.allCases.count
    }

    private var progress: Double {
        guard totalLevels > 0 else { return 0 }
        return Double(completedLevels) / Double(totalLevels)
    }

    var body: some View {
        SurfaceCard(highlighted: progress > 0.5) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppVisualStyle.primaryGradient)
                        .frame(width: 58, height: 58)
                        .overlay(
                            Circle()
                                .fill(AppVisualStyle.glossGradient)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color("AppTextPrimary").opacity(0.2), lineWidth: 1)
                        )
                        .appSoftShadow(.low)
                    Image(systemName: activity.iconName)
                        .font(.title2)
                        .foregroundStyle(Color("AppTextPrimary"))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                    Text(activity.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)

                    HStack(spacing: 8) {
                        ProgressView(value: progress)
                            .tint(Color("AppAccent"))
                        Text("\(completedLevels)/\(totalLevels)")
                            .font(.caption2.bold())
                            .foregroundStyle(Color("AppAccent"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }

                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color("AppPrimary"))
            }
            .padding(16)
        }
    }
}
