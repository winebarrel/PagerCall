import Foundation

enum Status: String {
    case notOnCallWithoutIncident = "bell.slash"
    case notOnCallWithIncident = "bell.badge.slash"
    case onCallWithoutIncident = "bell.fill"
    case onCallWithIncident = "bell.and.waves.left.and.right.fill"
    case error = "exclamationmark.triangle"
}

@MainActor
class PagerDuty: ObservableObject {
    private let endpoint = URL(string: "https://api.pagerduty.com/")!
    private let api = PagerDutyAPI()

    @Published var incidents: Incidents = []
    @Published var status: Status = .notOnCallWithoutIncident
    @Published var updatedAt: Date?
    @Published var error: Error?

    func update() async {
        do {
            let onCallNow = try await api.isOnCall()
            let currIncidents = try await api.getIncidents()
            let newIncidents = currIncidents - incidents
            let hasIncidents = !currIncidents.isEmpty

            incidents = currIncidents

            status = if onCallNow {
                hasIncidents ? Status.onCallWithIncident : Status.onCallWithoutIncident
            } else {
                hasIncidents ? Status.notOnCallWithIncident : Status.notOnCallWithoutIncident
            }

            updatedAt = Date()
            error = nil

            if !newIncidents.isEmpty {
                notify(newIncidents)
            }
        } catch {
            Logger.shared.error("failed to get incidents: \(error)")
            status = .error
            self.error = error
        }
    }

    private func notify(_ newIncidents: Incidents) {
        for inc in newIncidents {
            Task {
                let emoji = inc.urgency == .high ? "🚨" : "⚠️"

                await Notification.notify(
                    id: inc.id,
                    title: "\(emoji)PagerCall [\(inc.urgency)] on \(inc.service.summary)",
                    body: inc.title,
                    url: inc.htmlUrl
                )
            }
        }
    }
}
