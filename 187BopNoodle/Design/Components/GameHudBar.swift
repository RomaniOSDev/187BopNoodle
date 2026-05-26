import SwiftUI

struct GameHudBar: View {
    let onClose: () -> Void
    let leadingTitle: String
    let trailingItems: [(String, String)]

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.body.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(width: 36, height: 36)
                    .background(hudChipBackground)
                    .clipShape(Circle())
            }
            .appSoftShadow(.low)
            .frame(minWidth: 44, minHeight: 44)

            Text(leadingTitle)
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(hudChipBackground)
                .clipShape(Capsule())
                .appSoftShadow(.low)

            Spacer()

            ForEach(Array(trailingItems.enumerated()), id: \.offset) { _, item in
                VStack(alignment: .trailing, spacing: 2) {
                    Text(item.0)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(item.1)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(hudChipBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .appSoftShadow(.low)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    private var hudChipBackground: some View {
        AppVisualStyle.surfaceGradient
    }
}
