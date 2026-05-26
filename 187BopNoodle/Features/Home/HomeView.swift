import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var storage: GameStorage
    @Binding var selectedTab: MainTab

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroSection
                    galleryWidget
                    statsWidget
                    continueWidget
                    quickPlayWidget
                    achievementsWidget
                    meadowTipWidget
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(AnimatedPlayBackground())
            .navigationBarHidden(true)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        SurfaceCard(highlighted: true) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(greeting)
                            .font(.title2.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        Text("Your meadow is ready for the next leap")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    Spacer()
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(storage.totalStarsEarned)")
                            .font(.title.bold())
                            .foregroundStyle(Color("AppAccent"))
                        Text("⭐")
                            .font(.title3)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                }
                MeadowHeroIllustration(height: 150)
            }
            .padding(16)
        }
        .padding(.top, 8)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning, Jumper"
        case 12..<17: return "Good Afternoon, Jumper"
        case 17..<22: return "Good Evening, Jumper"
        default: return "Night Meadow Run"
        }
    }

    // MARK: - Gallery

    private var galleryWidget: some View {
        HomeWidgetCard(title: "Meadow Gallery", subtitle: "Scenes from your star path") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    galleryCard(title: "Leap Sprint", art: AnyView(SprintTrailIllustration()))
                    galleryCard(title: "Meadow Path", art: AnyView(MeadowPathIllustration()))
                    galleryCard(title: "Sky Glide", art: AnyView(GlideArcIllustration()))
                    galleryCard(title: "Star Field", art: AnyView(starFieldArt))
                }
            }
        }
    }

    private func galleryCard(title: String, art: AnyView) -> some View {
        VStack(spacing: 8) {
            art
                .frame(width: 120, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(10)
        .background(Color("AppBackground").opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var starFieldArt: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color("AppBackground"), Color("AppSurface")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            ForEach(0..<8, id: \.self) { i in
                Image(systemName: "star.fill")
                    .font(.system(size: CGFloat(10 + (i % 3) * 4)))
                    .foregroundStyle(Color("AppAccent").opacity(0.7))
                    .offset(
                        x: CGFloat([-36, -12, 18, 34, -28, 8, 28, -4][i]),
                        y: CGFloat([-18, 8, -8, 12, 20, -22, 4, 16][i])
                    )
            }
        }
        .frame(width: 100, height: 64)
    }

    // MARK: - Stats widget

    private var statsWidget: some View {
        HomeWidgetCard(title: "Today's Meadow Stats", subtitle: "Track your star journey") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                HomeStatWidget(
                    icon: "figure.run",
                    value: "\(storage.totalActivitiesPlayed)",
                    label: "Runs",
                    accent: true
                )
                HomeStatWidget(
                    icon: "star.fill",
                    value: "\(storage.totalStarsEarned)",
                    label: "Stars"
                )
                HomeStatWidget(
                    icon: "clock.fill",
                    value: storage.formattedPlayTime,
                    label: "Play Time"
                )
                HomeStatWidget(
                    icon: "flame.fill",
                    value: "\(storage.streakCount)d",
                    label: "Streak"
                )
            }
        }
    }

    // MARK: - Continue widget

    @ViewBuilder
    private var continueWidget: some View {
        if let resume = resumeTarget {
            HomeWidgetCard(
                title: "Continue Playing",
                subtitle: resume.subtitle,
                actionTitle: "Resume"
            ) {
                NavigationLink {
                    destinationView(for: resume)
                } label: {
                    HStack(spacing: 14) {
                        resume.artwork
                        VStack(alignment: .leading, spacing: 6) {
                            Text(resume.activityTitle)
                                .font(.subheadline.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text("Level \(resume.levelDisplay) · \(resume.difficulty.rawValue)")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                            StarRatingView(count: resume.stars, size: 14)
                        }
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
                .buttonStyle(.plain)
                .simultaneousGesture(TapGesture().onEnded {
                    HapticService.majorAction()
                })
            }
        }
    }

    // MARK: - Quick play widget

    private var quickPlayWidget: some View {
        HomeWidgetCard(
            title: "Quick Play",
            subtitle: "Pick a path and collect stars",
            actionTitle: "See All"
        ) {
            selectedTab = .play
        } content: {
            VStack(spacing: 10) {
                ForEach(ActivityInfo.all) { activity in
                    NavigationLink {
                        ActivitySelectionView(activity: activity)
                    } label: {
                        quickPlayRow(activity: activity)
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(TapGesture().onEnded {
                        HapticService.majorAction()
                    })
                }
            }
        }
    }

    private func quickPlayRow(activity: ActivityInfo) -> some View {
        HStack(spacing: 12) {
            activityArtwork(for: activity.id)
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(activity.subtitle)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
            Image(systemName: "chevron.right.circle.fill")
                .foregroundStyle(Color("AppAccent"))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppBackground").opacity(0.6),
                            Color("AppSurface").opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func activityArtwork(for activityId: String) -> some View {
        switch activityId {
        case "grasshopper_leap_sprint":
            SprintTrailIllustration()
        case "meadow_leap_challenge":
            MeadowPathIllustration()
        case "grasshopper_leap_glide":
            GlideArcIllustration()
        default:
            SprintTrailIllustration()
        }
    }

    // MARK: - Achievements widget

    private var achievementsWidget: some View {
        let unlocked = AchievementDefinition.all.filter { $0.isUnlocked(storage) }.count
        let total = AchievementDefinition.all.count

        return HomeWidgetCard(
            title: "Achievements",
            subtitle: "\(unlocked) of \(total) unlocked",
            actionTitle: "Open"
        ) {
            selectedTab = .achievements
        } content: {
            VStack(spacing: 10) {
                ProgressView(value: Double(unlocked), total: Double(total))
                    .tint(Color("AppAccent"))

                ForEach(AchievementDefinition.all.prefix(3)) { achievement in
                    HStack(spacing: 10) {
                        Image(systemName: achievement.iconName)
                            .font(.body)
                            .foregroundStyle(
                                achievement.isUnlocked(storage)
                                    ? Color("AppAccent")
                                    : Color("AppTextSecondary").opacity(0.4)
                            )
                            .frame(width: 28)
                        Text(achievement.title)
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer()
                        Image(
                            systemName: achievement.isUnlocked(storage)
                                ? "checkmark.circle.fill"
                                : "lock.fill"
                        )
                        .foregroundStyle(
                            achievement.isUnlocked(storage)
                                ? Color("AppAccent")
                                : Color("AppTextSecondary")
                        )
                    }
                }
            }
        }
    }

    // MARK: - Tip widget

    private var meadowTipWidget: some View {
        HomeWidgetCard(title: "Meadow Tip", subtitle: "Helpful hints for your run") {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").opacity(0.3))
                        .frame(width: 52, height: 52)
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppAccent"))
                }
                Text(dailyTip)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)
            }
        }
    }

    private var dailyTip: String {
        let tips = [
            "Double-tap on the ground for a high leap over logs in Leap Sprint.",
            "Swipe right to dash under bushes in Leap Glide.",
            "Earn at least 1 star on a level to unlock the next one.",
            "Build your daily streak by playing every day this week."
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return tips[day % tips.count]
    }

    // MARK: - Resume logic

    private struct ResumeTarget {
        let activityId: String
        let activityTitle: String
        let difficulty: GameDifficulty
        let level: Int
        let levelDisplay: Int
        let stars: Int
        let subtitle: String
        let artwork: AnyView
    }

    private var resumeTarget: ResumeTarget? {
        for activity in ActivityInfo.all {
            for difficulty in GameDifficulty.allCases {
                let highest = storage.highestUnlockedIndex(
                    activityId: activity.id,
                    difficulty: difficulty
                )
                let stars = storage.stars(
                    for: activity.id,
                    difficulty: difficulty,
                    level: highest
                )
                if stars < 3 {
                    return ResumeTarget(
                        activityId: activity.id,
                        activityTitle: activity.title,
                        difficulty: difficulty,
                        level: highest,
                        levelDisplay: highest + 1,
                        stars: stars,
                        subtitle: stars == 0 ? "Start your next challenge" : "Improve your star rating",
                        artwork: AnyView(activityArtworkView(activity.id))
                    )
                }
            }
        }
        return nil
    }

    @ViewBuilder
    private func activityArtworkView(_ id: String) -> some View {
        activityArtwork(for: id)
    }

    @ViewBuilder
    private func destinationView(for resume: ResumeTarget) -> some View {
        switch resume.activityId {
        case "grasshopper_leap_sprint":
            Activity1View(
                activityId: resume.activityId,
                difficulty: resume.difficulty,
                level: resume.level
            )
        case "meadow_leap_challenge":
            Activity2View(
                activityId: resume.activityId,
                difficulty: resume.difficulty,
                level: resume.level
            )
        case "grasshopper_leap_glide":
            Activity3View(
                activityId: resume.activityId,
                difficulty: resume.difficulty,
                level: resume.level
            )
        default:
            EmptyView()
        }
    }
}
