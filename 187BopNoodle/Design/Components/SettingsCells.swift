import SwiftUI

struct StatsOverviewCard: View {
    let activitiesPlayed: Int
    let totalStars: Int
    let playTime: String

    var body: some View {
        SurfaceCard(highlighted: true) {
            VStack(alignment: .leading, spacing: 14) {
                Label("Your Journey", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))

                HStack(spacing: 10) {
                    StatMiniCell(value: "\(activitiesPlayed)", label: "Runs", icon: "figure.run")
                    StatMiniCell(value: "\(totalStars)", label: "Stars", icon: "star.fill")
                    StatMiniCell(value: playTime, label: "Time", icon: "clock.fill")
                }
            }
            .padding(16)
        }
    }
}

struct StatMiniCell: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color("AppAccent"))
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppBackground").opacity(0.65),
                            Color("AppSurface").opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.18), lineWidth: 1)
        )
    }
}

struct SettingsRowCell: View {
    let title: String
    let subtitle: String?
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            HapticService.buttonTap()
            action()
        } label: {
            SurfaceCard {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                isDestructive
                                    ? LinearGradient(
                                        colors: [Color.red.opacity(0.35), Color.red.opacity(0.15)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    : LinearGradient(
                                        colors: [
                                            Color("AppPrimary").opacity(0.45),
                                            Color("AppAccent").opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .frame(width: 40, height: 40)
                        Image(systemName: icon)
                            .foregroundStyle(isDestructive ? Color.red : Color("AppAccent"))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.bold())
                            .foregroundStyle(isDestructive ? Color.red : Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        if let subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .padding(14)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .frame(minHeight: 44)
    }
}
