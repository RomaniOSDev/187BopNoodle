import UIKit

enum HapticService {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let notification = UINotificationFeedbackGenerator()

    static func buttonTap() {
        light.prepare()
        light.impactOccurred()
    }

    static func majorAction() {
        medium.prepare()
        medium.impactOccurred()
    }

    static func gameEvent() {
        medium.prepare()
        medium.impactOccurred()
    }

    static func screenShake() {
        heavy.prepare()
        heavy.impactOccurred()
    }

    static func success() {
        notification.prepare()
        notification.notificationOccurred(.success)
    }

    static func error() {
        notification.prepare()
        notification.notificationOccurred(.error)
    }
}
