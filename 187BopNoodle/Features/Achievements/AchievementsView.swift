import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var storage: GameStorage
    @State private var newlyUnlockedID: String?

    private var unlockedCount: Int {
        AchievementDefinition.all.filter { $0.isUnlocked(storage) }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenHeader(
                        title: "Achievements",
                        subtitle: "Complete challenges across your meadow journey",
                        trailing: "\(unlockedCount)/\(AchievementDefinition.all.count)"
                    )
                    .padding(.top, 8)

                    achievementsSummary

                    ForEach(AchievementDefinition.all) { achievement in
                        AchievementCell(
                            achievement: achievement,
                            isUnlocked: achievement.isUnlocked(storage),
                            animateUnlock: newlyUnlockedID == achievement.id
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(MeadowBackground())
            .onAppear { checkNewUnlocks() }
            .onChange(of: storage.totalStarsEarned) { _ in checkNewUnlocks() }
            .onChange(of: storage.totalActivitiesPlayed) { _ in checkNewUnlocks() }
        }
    }

    private var achievementsSummary: some View {
        SurfaceCard(highlighted: unlockedCount == AchievementDefinition.all.count) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Collection Progress")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    ProgressView(
                        value: Double(unlockedCount),
                        total: Double(AchievementDefinition.all.count)
                    )
                    .tint(Color("AppAccent"))
                }
                Image(systemName: "trophy.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color("AppAccent"))
            }
            .padding(16)
        }
    }

    private func checkNewUnlocks() {
        for achievement in AchievementDefinition.all where achievement.isUnlocked(storage) {
            if newlyUnlockedID == nil {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    newlyUnlockedID = achievement.id
                }
                HapticService.success()
            }
        }
    }
}
