import Foundation

struct IncidentsResp: Codable {
    let incidents: [Incident]
}

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

class PagerDuty: ObservableObject {
    private var apiKey: String?
    @Published var incidents: Incidents = []

    func configure(token: String) {
        apiKey = token
    }

    func update() {
        // TODO:
    }
}
