import Foundation
import Valet

enum Vault {
    static let shared = Valet.valet(with: Identifier(nonEmpty: Bundle.main.bundleIdentifier)!, accessibility: .whenUnlocked)

    static var apiKey: String {
        get {
            do {
                return try shared.string(forKey: "apiKey")
            } catch KeychainError.itemNotFound {
                // Nothing to do
            } catch {
                Logger.shared.error("failed to get apiKey from Valet: \(error)")
            }

            return ""
        }

        set(token) {
            do {
                if token.isEmpty {
                    try shared.removeObject(forKey: "apiKey")
                } else {
                    try shared.setString(token, forKey: "apiKey")
                }
            } catch {
                Logger.shared.error("failed to set apiKey to Valet: \(error)")
            }
        }
    }
}
