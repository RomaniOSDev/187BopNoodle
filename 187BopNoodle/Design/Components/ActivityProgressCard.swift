import SwiftUI

struct ActivityProgressCard: View {
    let activity: ActivityInfo
    let difficulty: GameDifficulty
    let storage: GameStorage

    private var clearedLevels: Int {
        (0..<activity.levelsPerDifficulty).filter { level in
            storage.stars(for: activity.id, difficulty: difficulty, level: level) > 0
        }.count
    }

    private var totalStars: Int {
        (0..<activity.levelsPerDifficulty).reduce(0) { sum, level in
            sum + storage.stars(for: activity.id, difficulty: difficulty, level: level)
        }
    }

    private var progress: Double {
        guard activity.levelsPerDifficulty > 0 else { return 0 }
        return Double(clearedLevels) / Double(activity.levelsPerDifficulty)
    }

    var body: some View {
        SurfaceCard(highlighted: clearedLevels > 0) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(difficulty.rawValue) Progress")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    ProgressView(value: progress)
                        .tint(Color("AppAccent"))
                    Text("\(clearedLevels) of \(activity.levelsPerDifficulty) levels cleared")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                VStack(spacing: 4) {
                    Text("\(totalStars)")
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppAccent"))
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("earned")
                            .font(.caption2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(16)
        }
    }
}
