import StoreKit
import UIKit

enum SettingsActions {
    static func openPrivacyPolicy() {
        if let url = URL(string: AppExternalLinks.privacyPolicy.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    static func openTermsOfService() {
        guard let url = AppExternalLinks.termsOfService.url else { return }
        UIApplication.shared.open(url)
    }

    static func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
