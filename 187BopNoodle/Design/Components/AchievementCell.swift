import SwiftUI

struct AchievementCell: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool
    var animateUnlock: Bool = false
    @State private var scale: CGFloat = 1

    var body: some View {
        SurfaceCard(highlighted: isUnlocked) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                isUnlocked
                                    ? AppVisualStyle.primaryGradient
                                    : LinearGradient(
                                        colors: [
                                            Color("AppSurface"),
                                            Color("AppBackground").opacity(0.8)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                            )
                            .frame(width: 48, height: 48)
                        Image(systemName: achievement.iconName)
                            .font(.title3)
                            .foregroundStyle(
                                isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary").opacity(0.5)
                            )
                    }
                    .scaleEffect(scale)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(achievement.title)
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        statusBadge
                    }
                    Spacer(minLength: 0)
                }

                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
        }
        .onChange(of: animateUnlock) { newValue in
            guard newValue, isUnlocked else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { scale = 1.12 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { scale = 1 }
            }
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        Text(isUnlocked ? "Unlocked" : "Locked")
            .font(.caption2.bold())
            .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(isUnlocked ? Color("AppAccent").opacity(0.35) : Color("AppBackground").opacity(0.5))
            .clipShape(Capsule())
    }
}
