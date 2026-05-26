import Foundation

enum AppExternalLinks: String {
    case privacyPolicy = "https://bopnoodle187.site/privacy/207"
    case termsOfService = "https://bopnoodle187.site/terms/207"

    var url: URL? {
        URL(string: rawValue)
    }
}
