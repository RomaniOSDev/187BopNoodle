import Foundation

enum GameDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"

    var id: String { rawValue }

    var storageKey: String { rawValue.lowercased() }
}
