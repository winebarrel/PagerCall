import Foundation
import SwiftUI

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

    @AppStorage("userID") private var userID: String = ""
    @Published var incidents: Incidents = []
    @Published var status: Status = .notOnCallWithoutIncident
    @Published var updatedAt: Date?

    func update() async throws {
        let userID = try await getUserID()
        let onCallNow = try await isOnCall(userID)
        let currIncidents = try await getIncidents(userID)
        let hasIncidents = currIncidents.count > 0

        incidents.replaceAll(currIncidents)

        if onCallNow {
            status = hasIncidents ?.onCallWithIncident : .onCallWithoutIncident
        } else {
            status = hasIncidents ? .notOnCallWithIncident : .notOnCallWithoutIncident
        }

        let newIncidents = currIncidents - incidents

        if newIncidents.count > 0 {
            notify(newIncidents)
        }

        updatedAt = Date()
    }

    private func notify(_ newIncidents: Incidents) {
        // TODO:
    }

    struct UsersMeResp: Codable {
        let user: User

        struct User: Codable {
            let id: String
        }
    }

    private func getUserID() async throws -> String {
        if !userID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return userID
        }

        let data = try await get("/users/me")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(UsersMeResp.self, from: data)

        return resp.user.id
    }

    struct OncallsResp: Codable {
        let oncalls: [Oncall]
        struct Oncall: Codable {}
    }

    private func isOnCall(_ userID: String) async throws -> Bool {
        let data = try await get("/oncalls", ["user_ids[]": userID])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(OncallsResp.self, from: data)

        return resp.oncalls.count >= 1
    }

    struct IncidentsResp: Codable {
        let incidents: Incidents
    }

    private func getIncidents(_ userID: String) async throws -> Incidents {
        let data = try await get("/incidents", ["user_ids[]": userID])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(IncidentsResp.self, from: data)

        return resp.incidents
    }

    private func get(_ path: String, _ query: [String: String] = [:]) async throws -> Data {
        var url = endpoint.appendingPathComponent(path)
        url.append(queryItems: query.map { key, val in URLQueryItem(name: key, value: val) })

        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Token token=\(Vault.apiKey)", forHTTPHeaderField: "Authorization")

        let (data, rawResp) = try await URLSession.shared.data(for: req)

        guard let resp = rawResp as? HTTPURLResponse else {
            fatalError("failed to cast URLResponse to HTTPURLResponse")
        }

        if resp.statusCode != 200 {
            throw PagerDutyError.respNotOK(resp)
        }

        return data
    }
}

enum PagerDutyError: LocalizedError {
    case respNotOK(HTTPURLResponse)

    var errorDescription: String? {
        switch self {
        case let .respNotOK(resp):
            let statusCode = resp.statusCode
            let statusMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            return "PagerDuty API error: \(statusCode) \(statusMessage)"
        }
    }
}
