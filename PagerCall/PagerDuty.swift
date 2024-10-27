import Foundation

struct Incident: Codable, Identifiable {
    let id: String
    let title: String
    let htmlUrl: String
}

typealias Incidents = [Incident]

extension Incidents {
    mutating func replaceAll(_ newIncidents: Incidents) {
        replaceSubrange(0 ..< count, with: newIncidents)
    }
}

func - (left: Incidents, right: Incidents) -> Incidents {
    let rightIDs = right.map { $0.id }
    return left.filter { !rightIDs.contains($0.id) }
}

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

            let newIncidents = currIncidents - incidents

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
        // TODO:
    }
}
