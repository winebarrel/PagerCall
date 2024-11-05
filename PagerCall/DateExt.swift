import Foundation

extension Date {
    func relative() -> String {
        let dtfmt = RelativeDateTimeFormatter()
        dtfmt.unitsStyle = .abbreviated
        return dtfmt.localizedString(for: self, relativeTo: Date())
    }

    func shortTime() -> String {
        let dtfmt = DateFormatter()
        dtfmt.dateStyle = .none
        dtfmt.timeStyle = .short
        return dtfmt.string(from: self)
    }
}
