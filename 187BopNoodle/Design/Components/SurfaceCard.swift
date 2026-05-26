import SwiftUI

struct SurfaceCard<Content: View>: View {
    var cornerRadius: CGFloat = 16
    var highlighted: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(cardBackground)
            .overlay(glossOverlay)
            .overlay(borderOverlay)
            .appSoftShadow(highlighted ? .high : .medium)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppVisualStyle.surfaceGradient)
    }

    private var glossOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppVisualStyle.glossGradient)
            .allowsHitTesting(false)
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                AppVisualStyle.borderGradient(highlighted: highlighted),
                lineWidth: highlighted ? 1.5 : 1
            )
            .allowsHitTesting(false)
    }
}

struct ScreenHeader: View {
    let title: String
    var subtitle: String?
    var trailing: String?

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
            Spacer(minLength: 8)
            if let trailing {
                Text(trailing)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(AppVisualStyle.primaryGradient)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color("AppTextPrimary").opacity(0.2), lineWidth: 1)
                    )
                    .appSoftShadow(.low)
            }
        }
    }
}
