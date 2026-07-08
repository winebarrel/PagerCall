import Foundation

enum Region: String, CaseIterable {
    // swiftlint:disable identifier_name
    case us = "US"
    case eu = "EU"
    // swiftlint:enable identifier_name

    var apiEndpoint: URL {
        switch self {
        case .us:
            return URL(string: "https://api.pagerduty.com/")!
        case .eu:
            return URL(string: "https://api.eu.pagerduty.com/")!
        }
    }

    func webBaseURL(subdomain: String) -> URL {
        switch self {
        case .us:
            return URL(string: "https://\(subdomain).pagerduty.com")!
        case .eu:
            return URL(string: "https://\(subdomain).eu.pagerduty.com")!
        }
    }
}
