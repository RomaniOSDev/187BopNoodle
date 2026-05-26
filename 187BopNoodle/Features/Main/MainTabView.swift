import SwiftUI

enum MainTab: Int, CaseIterable {
    case home
    case play
    case achievements
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .play: return "Play"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .play: return "gamecontroller"
        case .achievements: return "trophy"
        case .settings: return "gearshape"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            MeadowBackground()
            Group {
                switch selectedTab {
                case .home:
                    HomeView(selectedTab: $selectedTab)
                case .play:
                    PlayTabView()
                case .achievements:
                    AchievementsView()
                case .settings:
                    SettingsView()
                }
            }
            .padding(.bottom, 88)

            CustomTabBarView(selectedTab: $selectedTab)
                .padding(.bottom, 8)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
