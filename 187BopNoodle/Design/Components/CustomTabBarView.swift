import SwiftUI

struct CustomTabBarView: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 6) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                Button {
                    HapticService.buttonTap()
                    withAnimation(.easeOut(duration: 0.22)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: iconName(for: tab, isSelected: selectedTab == tab))
                            .font(.system(size: 20, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2.bold())
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(
                        selectedTab == tab ? Color("AppTextPrimary") : Color("AppTextSecondary")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(tabSelectionBackground(isSelected: selectedTab == tab))
                    .overlay(
                        Group {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppVisualStyle.glossGradient)
                            }
                        }
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .frame(minHeight: 44)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(tabBarBackground)
        .appSoftShadow(.high)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func tabSelectionBackground(isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppVisualStyle.primaryGradient)
        }
    }

    private var tabBarBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(AppVisualStyle.surfaceGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(AppVisualStyle.borderGradient(highlighted: false), lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppVisualStyle.glossGradient)
                    .allowsHitTesting(false)
            )
    }

    private func iconName(for tab: MainTab, isSelected: Bool) -> String {
        switch tab {
        case .home: return isSelected ? "house.fill" : "house"
        case .play: return isSelected ? "gamecontroller.fill" : "gamecontroller"
        case .achievements: return isSelected ? "trophy.fill" : "trophy"
        case .settings: return isSelected ? "gearshape.fill" : "gearshape"
        }
    }
}
