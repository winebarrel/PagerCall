import Foundation
import os

enum Logger {
    static let shared = os.Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "main"
    )
}
