import Foundation

enum Status: String {
    case notOnCallWithoutIncident = "bell.slash"
    case notOnCallWithIncident = "bell.badge.slash"
    case onCallWithoutIncident = "bell.fill"
    case onCallWithIncident = "bell.and.waves.left.and.right.fill"
    case error = "exclamationmark.triangle"
}

@MainActor
class PagerDutyModel: ObservableObject {
    private let api = PagerDutyAPI()

    @Published var incidents: Incidents = []
    @Published var status: Status = .notOnCallWithoutIncident
    @Published var updatedAt: Date?
    @Published var error: PagerDutyError?

    func update(_ apiKey: String) async {
        do {
            let onCallNow = try await api.isOnCall(apiKey)
            let currIncidents = try await api.getIncidents(apiKey)
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
        } catch let pdErr as PagerDutyError {
            status = .error
            error = pdErr
            updatedAt = nil
        } catch {
            Logger.shared.error("failed to get incidents: \(error)")
        }
    }

    private func notify(_ newIncidents: Incidents) {
        for inc in newIncidents {
            Task {
                let emoji = inc.urgency == .high ? "🚨" : "⚠️"

                await Notification.notify(
                    id: inc.id,
                    title: "\(emoji) [\(inc.urgency)] on \(inc.service.summary) #\(String(inc.incidentNumber))",
                    body: inc.title,
                    url: inc.htmlUrl
                )
            }
        }
    }
}
