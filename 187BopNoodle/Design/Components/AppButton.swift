import SwiftUI

struct AppButton: View {
    let title: String
    var style: Style = .primary
    var isDestructive: Bool = false
    let action: () -> Void

    enum Style {
        case primary
        case secondary
    }

    var body: some View {
        Button {
            HapticService.buttonTap()
            action()
        } label: {
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .background(backgroundShape)
                .overlay(glossOverlay)
                .overlay(borderOverlay)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .appSoftShadow(style == .primary ? .medium : .low)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    @ViewBuilder
    private var backgroundShape: some View {
        if isDestructive {
            LinearGradient(
                colors: [Color.red.opacity(0.9), Color.red.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else if style == .primary {
            AppVisualStyle.primaryGradient
        } else {
            AppVisualStyle.surfaceGradient
        }
    }

    @ViewBuilder
    private var glossOverlay: some View {
        if !isDestructive {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppVisualStyle.glossGradient)
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(
                style == .primary
                    ? Color("AppTextPrimary").opacity(0.18)
                    : Color("AppPrimary").opacity(0.28),
                lineWidth: 1
            )
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}
