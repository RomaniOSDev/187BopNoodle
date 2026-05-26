import SwiftUI

struct PlayTabView: View {
    @EnvironmentObject private var storage: GameStorage

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenHeader(
                        title: "All Activities",
                        subtitle: "Choose a game and difficulty level",
                        trailing: "\(storage.totalStarsEarned) ⭐"
                    )
                    .padding(.top, 8)

                    quickStatsRow

                    Text("Choose Your Path")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))

                    ForEach(ActivityInfo.all) { activity in
                        NavigationLink {
                            ActivitySelectionView(activity: activity)
                        } label: {
                            ActivityCardCell(activity: activity)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded {
                            HapticService.majorAction()
                        })
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(AnimatedPlayBackground())
            .navigationBarHidden(true)
        }
    }

    private var quickStatsRow: some View {
        HStack(spacing: 10) {
            quickStat(icon: "figure.run", value: "\(storage.totalActivitiesPlayed)", label: "Runs")
            quickStat(icon: "clock.fill", value: storage.formattedPlayTime, label: "Played")
            quickStat(icon: "flame.fill", value: "\(storage.streakCount)d", label: "Streak")
        }
    }

    private func quickStat(icon: String, value: String, label: String) -> some View {
        HomeStatWidget(icon: icon, value: value, label: label, accent: label == "Streak")
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppVisualStyle.surfaceGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppVisualStyle.borderGradient(highlighted: false), lineWidth: 1)
            )
            .appSoftShadow(.low)
    }
}
