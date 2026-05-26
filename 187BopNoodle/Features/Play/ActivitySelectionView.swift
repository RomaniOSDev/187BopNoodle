import SwiftUI

struct ActivitySelectionView: View {
    @EnvironmentObject private var storage: GameStorage
    let activity: ActivityInfo
    @State private var difficulty: GameDifficulty = .easy
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(
                    title: activity.title,
                    subtitle: activity.subtitle,
                    trailing: difficulty.rawValue
                )

                ActivityProgressCard(
                    activity: activity,
                    difficulty: difficulty,
                    storage: storage
                )

                Text("Select Difficulty")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))

                DifficultyPickerView(selection: $difficulty)

                Text("Levels")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<activity.levelsPerDifficulty, id: \.self) { level in
                        levelCell(level: level)
                    }
                }
            }
            .padding(16)
        }
        .background(MeadowBackground())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    HapticService.buttonTap()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppVisualStyle.surfaceGradient)
                    .overlay(
                        Capsule()
                            .stroke(Color("AppPrimary").opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(Capsule())
                    .appSoftShadow(.low)
                }
                .frame(minWidth: 44, minHeight: 44)
            }
        }
    }

    private var recommendedLevel: Int {
        storage.highestUnlockedIndex(activityId: activity.id, difficulty: difficulty)
    }

    @ViewBuilder
    private func levelCell(level: Int) -> some View {
        let unlocked = storage.isLevelUnlocked(
            activityId: activity.id,
            difficulty: difficulty,
            level: level
        )
        let stars = storage.stars(
            for: activity.id,
            difficulty: difficulty,
            level: level
        )

        if unlocked {
            NavigationLink {
                gameView(for: level)
            } label: {
                LevelGridCell(
                    levelNumber: level + 1,
                    stars: stars,
                    isLocked: false,
                    isRecommended: level == recommendedLevel && stars < 3
                )
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
                HapticService.majorAction()
            })
        } else {
            LevelGridCell(
                levelNumber: level + 1,
                stars: stars,
                isLocked: true,
                isRecommended: false
            )
        }
    }

    @ViewBuilder
    private func gameView(for level: Int) -> some View {
        switch activity.id {
        case "grasshopper_leap_sprint":
            Activity1View(activityId: activity.id, difficulty: difficulty, level: level)
        case "meadow_leap_challenge":
            Activity2View(activityId: activity.id, difficulty: difficulty, level: level)
        case "grasshopper_leap_glide":
            Activity3View(activityId: activity.id, difficulty: difficulty, level: level)
        default:
            EmptyView()
        }
    }
}
