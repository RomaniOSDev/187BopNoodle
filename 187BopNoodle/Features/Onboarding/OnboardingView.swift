import SwiftUI

private struct OnboardingPageData: Identifiable {
    let id: Int
    let headline: String
    let bodyText: String
    let icon: String
    let hint: String
    let illustration: AnyView

    static let all: [OnboardingPageData] = [
        OnboardingPageData(
            id: 0,
            headline: "Jump High",
            bodyText: "Tap to make the grasshopper leap over obstacles.",
            icon: "arrow.up.circle.fill",
            hint: "Tap & double-tap to leap",
            illustration: AnyView(OnboardingJumpIllustration())
        ),
        OnboardingPageData(
            id: 1,
            headline: "Collect Stars",
            bodyText: "Earn STARS ⭐ by gathering them during your journey.",
            icon: "star.circle.fill",
            hint: "Timing earns more stars",
            illustration: AnyView(OnboardingStarsIllustration())
        ),
        OnboardingPageData(
            id: 2,
            headline: "Start Your Adventure",
            bodyText: "Ready, set, go! Begin your star-collecting quest.",
            icon: "flag.checkered.circle.fill",
            hint: "Three meadow games await",
            illustration: AnyView(OnboardingAdventureIllustration())
        )
    ]
}

struct OnboardingView: View {
    @EnvironmentObject private var storage: GameStorage
    @State private var currentPage = 0

    private var pages: [OnboardingPageData] { OnboardingPageData.all }
    private var progress: Double {
        Double(currentPage + 1) / Double(pages.count)
    }

    var body: some View {
        ZStack {
            LayeredAppBackground(depth: .standard)

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        pageView(page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.28), value: currentPage)

                bottomControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Top

    private var topBar: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(Color("AppAccent"))
                    Text("Meadow Guide")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        HapticService.buttonTap()
                        finishOnboarding()
                    }
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                    .frame(minWidth: 44, minHeight: 44)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Step \(currentPage + 1) of \(pages.count)")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                }
                ProgressView(value: progress)
                    .tint(Color("AppAccent"))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppVisualStyle.surfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.22), lineWidth: 1)
        )
        .appSoftShadow(.low)
    }

    // MARK: - Page

    private func pageView(_ page: OnboardingPageData) -> some View {
        ScrollView {
            VStack(spacing: 18) {
                page.illustration
                    .padding(.horizontal, 20)

                SurfaceCard(highlighted: true) {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppVisualStyle.primaryGradient)
                                    .frame(width: 44, height: 44)
                                Image(systemName: page.icon)
                                    .font(.title3)
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                            .appSoftShadow(.low)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(page.headline)
                                    .font(.title2.bold())
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                Text(page.hint)
                                    .font(.caption.bold())
                                    .foregroundStyle(Color("AppAccent"))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            Spacer(minLength: 0)
                        }

                        Text(page.bodyText)
                            .font(.body)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(4)
                            .minimumScaleFactor(0.85)
                    }
                    .padding(20)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
        }
    }

    // MARK: - Bottom

    private var bottomControls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == currentPage
                                ? Color("AppPrimary")
                                : Color("AppTextSecondary").opacity(0.35)
                        )
                        .frame(width: index == currentPage ? 28 : 8, height: 8)
                        .animation(.easeOut(duration: 0.25), value: currentPage)
                }
            }

            AppButton(title: currentPage < pages.count - 1 ? "Next" : "Get Started") {
                if currentPage < pages.count - 1 {
                    HapticService.buttonTap()
                    withAnimation(.easeInOut(duration: 0.28)) {
                        currentPage += 1
                    }
                } else {
                    finishOnboarding()
                }
            }
        }
    }

    private func finishOnboarding() {
        HapticService.majorAction()
        storage.completeOnboarding()
    }
}
