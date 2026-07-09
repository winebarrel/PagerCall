import Foundation

enum Constants {
    static let defaultInterval: TimeInterval = 60
    /// PagerDuty subdomains consist of alphanumerics and hyphens. Restricting input to
    /// these characters keeps the constructed URL valid and avoids a crash in webBaseURL.
    static let subdomainAllowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-")
}
