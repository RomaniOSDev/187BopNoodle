import SwiftUI

struct DifficultyPickerView: View {
    @Binding var selection: GameDifficulty

    var body: some View {
        HStack(spacing: 8) {
            ForEach(GameDifficulty.allCases) { difficulty in
                Button {
                    HapticService.buttonTap()
                    withAnimation(.easeOut(duration: 0.22)) {
                        selection = difficulty
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: icon(for: difficulty))
                            .font(.body.bold())
                        Text(difficulty.rawValue)
                            .font(.caption.bold())
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(
                        selection == difficulty
                            ? Color("AppTextPrimary")
                            : Color("AppTextSecondary")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(cellBackground(isSelected: selection == difficulty))
                    .overlay(
                        Group {
                            if selection == difficulty {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppVisualStyle.glossGradient)
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                selection == difficulty
                                    ? Color("AppAccent").opacity(0.8)
                                    : Color("AppPrimary").opacity(0.15),
                                lineWidth: selection == difficulty ? 1.5 : 1
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
                .frame(minHeight: 44)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppVisualStyle.surfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.2), lineWidth: 1)
        )
        .appSoftShadow(.low)
    }

    @ViewBuilder
    private func cellBackground(isSelected: Bool) -> some View {
        if isSelected {
            AppVisualStyle.primaryGradient
        } else {
            Color("AppBackground").opacity(0.45)
        }
    }

    private func icon(for difficulty: GameDifficulty) -> String {
        switch difficulty {
        case .easy: return "leaf.fill"
        case .normal: return "wind"
        case .hard: return "bolt.fill"
        }
    }
}
