import SwiftUI

struct HomeWidgetCard<Content: View>: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?
    @ViewBuilder let content: () -> Content

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        if let subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                    }
                    Spacer()
                    if let actionTitle, let action {
                        Button(action: {
                            HapticService.buttonTap()
                            action()
                        }) {
                            Text(actionTitle)
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppVisualStyle.primaryGradient)
                                .clipShape(Capsule())
                        }
                        .frame(minHeight: 44)
                    }
                }
                content()
            }
            .padding(16)
        }
    }
}

struct HomeStatWidget: View {
    let icon: String
    let value: String
    let label: String
    var accent: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(accent ? Color("AppAccent") : Color("AppPrimary"))
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
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppBackground").opacity(0.7),
                            Color("AppSurface").opacity(0.35)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.2), lineWidth: 1)
        )
    }
}
