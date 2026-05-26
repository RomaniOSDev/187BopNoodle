import Foundation
import Combine

final class GameStorage: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let totalStarsEarned = "totalStarsEarned"
        static let totalPlayTimeSeconds = "totalPlayTimeSeconds"
        static let starsPerActivity = "starsPerActivity"
        static let unlockedLevels = "unlockedLevels"
        static let streakCount = "streakCount"
        static let lastPlayDate = "lastPlayDate"
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalActivitiesPlayed: Int {
        didSet { defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed) }
    }

    @Published var totalStarsEarned: Int {
        didSet { defaults.set(totalStarsEarned, forKey: Keys.totalStarsEarned) }
    }

    @Published var totalPlayTimeSeconds: Int {
        didSet { defaults.set(totalPlayTimeSeconds, forKey: Keys.totalPlayTimeSeconds) }
    }

    @Published var starsPerActivity: [String: [String: [Int]]] {
        didSet { persistStars() }
    }

    @Published var unlockedLevels: [String: [String: Int]] {
        didSet { persistUnlocks() }
    }

    @Published var streakCount: Int {
        didSet { defaults.set(streakCount, forKey: Keys.streakCount) }
    }

    private var lastPlayDateString: String {
        get { defaults.string(forKey: Keys.lastPlayDate) ?? "" }
        set { defaults.set(newValue, forKey: Keys.lastPlayDate) }
    }

    private let defaults: UserDefaults
    private var cancellables = Set<AnyCancellable>()

    var hasPerfectThreeStarRun: Bool {
        starsPerActivity.values
            .flatMap(\.values)
            .flatMap { $0 }
            .contains(3)
    }

    var totalUnlockedLevelSlots: Int {
        var count = 0
        for activity in ActivityInfo.all {
            for difficulty in GameDifficulty.allCases {
                let highest = highestUnlockedIndex(activityId: activity.id, difficulty: difficulty)
                count += max(0, highest + 1)
            }
        }
        return count
    }

    var formattedPlayTime: String {
        let hours = totalPlayTimeSeconds / 3600
        let minutes = (totalPlayTimeSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalStarsEarned = defaults.integer(forKey: Keys.totalStarsEarned)
        totalPlayTimeSeconds = defaults.integer(forKey: Keys.totalPlayTimeSeconds)
        streakCount = defaults.integer(forKey: Keys.streakCount)

        if let data = defaults.data(forKey: Keys.starsPerActivity),
           let decoded = try? JSONDecoder().decode([String: [String: [Int]]].self, from: data) {
            starsPerActivity = decoded
        } else {
            starsPerActivity = [:]
        }

        if let data = defaults.data(forKey: Keys.unlockedLevels),
           let decoded = try? JSONDecoder().decode([String: [String: Int]].self, from: data) {
            unlockedLevels = decoded
        } else {
            unlockedLevels = [:]
        }

        NotificationCenter.default.publisher(for: .progressReset)
            .sink { [weak self] _ in
                self?.reloadFromDefaults()
            }
            .store(in: &cancellables)
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
    }

    func recordPlaySession(durationSeconds: Int) {
        totalActivitiesPlayed += 1
        totalPlayTimeSeconds += durationSeconds
        updateStreak()
    }

    func stars(for activityId: String, difficulty: GameDifficulty, level: Int) -> Int {
        let key = difficulty.storageKey
        guard let levels = starsPerActivity[activityId]?[key], level < levels.count else {
            return 0
        }
        return levels[level]
    }

    func saveStars(_ stars: Int, activityId: String, difficulty: GameDifficulty, level: Int) {
        let key = difficulty.storageKey
        var activityStars = starsPerActivity[activityId] ?? [:]
        var levels = activityStars[key] ?? Array(repeating: 0, count: ActivityInfo.levelsPerDifficulty)
        while levels.count <= level {
            levels.append(0)
        }
        let previous = levels[level]
        if stars > previous {
            totalStarsEarned += stars - previous
            levels[level] = stars
            activityStars[key] = levels
            starsPerActivity[activityId] = activityStars
        }
        unlockNextLevelIfNeeded(activityId: activityId, difficulty: difficulty, level: level, earned: stars)
    }

    func isLevelUnlocked(activityId: String, difficulty: GameDifficulty, level: Int) -> Bool {
        level <= highestUnlockedIndex(activityId: activityId, difficulty: difficulty)
    }

    func highestUnlockedIndex(activityId: String, difficulty: GameDifficulty) -> Int {
        unlockedLevels[activityId]?[difficulty.storageKey] ?? 0
    }

    func resetAllProgress() {
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
        }
        defaults.synchronize()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .progressReset, object: nil)
    }

    private func unlockNextLevelIfNeeded(
        activityId: String,
        difficulty: GameDifficulty,
        level: Int,
        earned: Int
    ) {
        guard earned >= 1 else { return }
        let key = difficulty.storageKey
        var activityUnlocks = unlockedLevels[activityId] ?? [:]
        let current = activityUnlocks[key] ?? 0
        let nextIndex = level + 1
        if nextIndex > current && nextIndex < ActivityInfo.levelsPerDifficulty {
            activityUnlocks[key] = nextIndex
            unlockedLevels[activityId] = activityUnlocks
        }
    }

    private func updateStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterday = formatter.string(from: yesterdayDate)

        if lastPlayDateString == today {
            return
        } else if lastPlayDateString == yesterday {
            streakCount += 1
        } else {
            streakCount = 1
        }
        lastPlayDateString = today
    }

    private func persistStars() {
        if let data = try? JSONEncoder().encode(starsPerActivity) {
            defaults.set(data, forKey: Keys.starsPerActivity)
        }
    }

    private func persistUnlocks() {
        if let data = try? JSONEncoder().encode(unlockedLevels) {
            defaults.set(data, forKey: Keys.unlockedLevels)
        }
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalStarsEarned = defaults.integer(forKey: Keys.totalStarsEarned)
        totalPlayTimeSeconds = defaults.integer(forKey: Keys.totalPlayTimeSeconds)
        streakCount = defaults.integer(forKey: Keys.streakCount)

        if let data = defaults.data(forKey: Keys.starsPerActivity),
           let decoded = try? JSONDecoder().decode([String: [String: [Int]]].self, from: data) {
            starsPerActivity = decoded
        } else {
            starsPerActivity = [:]
        }

        if let data = defaults.data(forKey: Keys.unlockedLevels),
           let decoded = try? JSONDecoder().decode([String: [String: Int]].self, from: data) {
            unlockedLevels = decoded
        } else {
            unlockedLevels = [:]
        }
    }
}
