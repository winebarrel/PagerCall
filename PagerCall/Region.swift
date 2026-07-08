import Foundation

enum Region: String, CaseIterable {
    case us = "US"
    case eu = "EU"

    var apiEndpoint: URL {
        switch self {
        case .us:
            return URL(string: "https://api.pagerduty.com/")!
        case .eu:
            return URL(string: "https://api.eu.pagerduty.com/")!
        }
    }
}
