import SwiftUI

struct LevelGridCell: View {
    let levelNumber: Int
    let stars: Int
    let isLocked: Bool
    let isRecommended: Bool

    var body: some View {
        SurfaceCard(highlighted: stars == 3) {
            ZStack {
                if isLocked {
                    lockedContent
                } else {
                    unlockedContent
                }
            }
            .frame(maxWidth: .infinity, minHeight: 96)
            .padding(12)
        }
        .opacity(isLocked ? 0.55 : 1)
    }

    private var unlockedContent: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(levelNumber)")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                if isRecommended {
                    Text("GO")
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(AppVisualStyle.primaryGradient)
                        .clipShape(Capsule())
                        .appSoftShadow(.low)
                }
            }
            StarRatingView(count: stars, size: 14)
            HStack(spacing: 4) {
                Image(systemName: "play.fill")
                    .font(.caption2)
                Text("Play")
                    .font(.caption.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color("AppAccent"))
        }
    }

    private var lockedContent: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.title2)
                .foregroundStyle(Color("AppTextSecondary"))
            Text("Level \(levelNumber)")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("Earn 1⭐ on prior level")
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary").opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
    }
}
