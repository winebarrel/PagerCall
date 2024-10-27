import Foundation

enum Status: String {
    case notOnCallWithoutIncident = "bell.slash"
    case notOnCallWithIncident = "bell.badge.slash"
    case onCallWithoutIncident = "bell.fill"
    case onCallWithIncident = "bell.and.waves.left.and.right.fill"
    case error = "exclamationmark.triangle"
}

class PagerDuty: ObservableObject {
    private let endpoint = URL(string: "https://api.pagerduty.com/")!
    private let api = PagerDutyAPI()

    @Published var incidents: Incidents = []
    @Published var status: Status = .notOnCallWithoutIncident
    @Published var updatedAt: Date?
    @Published var error: Error?

    func update() async {
        do {
            let userID = try await api.getUserID()
            let onCallNow = try await api.isOnCall(userID)
            let currIncidents = try await api.getIncidents(userID)
            let newIncidents = currIncidents - incidents
            let hasIncidents = !currIncidents.isEmpty

            await MainActor.run {
                self.incidents.replaceAll(currIncidents)

                self.status = if onCallNow {
                    hasIncidents ? Status.onCallWithIncident : Status.onCallWithoutIncident
                } else {
                    hasIncidents ? Status.notOnCallWithIncident : Status.notOnCallWithoutIncident
                }

                self.updatedAt = Date()
                self.error = nil
            }

            if !newIncidents.isEmpty {
                notify(newIncidents)
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }

    private func notify(_ newIncidents: Incidents) {
        for inc in newIncidents {
            Task {
                await Notification.notify(
                    id: inc.id,
                    body: inc.title,
                    url: inc.htmlUrl
                )
            }
        }
    }
}
