import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var storage: GameStorage
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenHeader(
                        title: "Settings",
                        subtitle: "Progress, legal, and app preferences"
                    )
                    .padding(.top, 8)

                    StatsOverviewCard(
                        activitiesPlayed: storage.totalActivitiesPlayed,
                        totalStars: storage.totalStarsEarned,
                        playTime: storage.formattedPlayTime
                    )

                    Text("App")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))

                    SettingsRowCell(
                        title: "Rate Us",
                        subtitle: "Enjoying the meadow? Leave a review",
                        icon: "star.bubble.fill"
                    ) {
                        HapticService.buttonTap()
                        SettingsActions.rateApp()
                    }

                    SettingsRowCell(
                        title: "Privacy Policy",
                        subtitle: "Read how we handle your data",
                        icon: "hand.raised.fill"
                    ) {
                        HapticService.buttonTap()
                        SettingsActions.openPrivacyPolicy()
                    }

                    SettingsRowCell(
                        title: "Terms of Service",
                        subtitle: "Usage terms and conditions",
                        icon: "doc.text.fill"
                    ) {
                        HapticService.buttonTap()
                        SettingsActions.openTermsOfService()
                    }

                    Text("Data")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))

                    SettingsRowCell(
                        title: "Reset All Progress",
                        subtitle: "Clears stars, levels, and stats",
                        icon: "trash.fill",
                        isDestructive: true
                    ) {
                        showResetAlert = true
                    }

                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(MeadowBackground())
            .alert("Reset All Progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {
                    HapticService.buttonTap()
                }
                Button("Reset", role: .destructive) {
                    HapticService.error()
                    storage.resetAllProgress()
                }
            } message: {
                Text("This will erase all stars, levels, and statistics. This cannot be undone.")
            }
        }
    }
}
