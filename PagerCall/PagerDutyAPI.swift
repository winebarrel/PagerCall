import SwiftUI

struct Incident: Codable, Identifiable {
    let id: String
    let title: String
    let htmlUrl: String
    let urgency: Urgency

    enum Urgency: String, Codable {
        case high
        case low
    }
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

struct PagerDutyAPI {
    private let endpoint = URL(string: "https://api.pagerduty.com/")!

    @AppStorage("userID") private var userID: String = ""

    private struct UsersMeResp: Codable {
        let user: User

        struct User: Codable {
            let id: String
            let htmlUrl: String
        }
    }

    func getUserID() async throws -> String {
        if !userID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return userID
        }

        let user = try await getUser()

        return user.id
    }

    private func getUser() async throws -> UsersMeResp.User {
        let data = try await get("/users/me")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(UsersMeResp.self, from: data)

        return resp.user
    }

    private struct OncallsResp: Codable {
        let oncalls: [Oncall]
        struct Oncall: Codable {}
    }

    func isOnCall(_ userID: String) async throws -> Bool {
        let data = try await get("/oncalls", ["user_ids[]": userID])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(OncallsResp.self, from: data)

        return resp.oncalls.count >= 1
    }

    private struct IncidentsResp: Codable {
        let incidents: Incidents
    }

    func getIncidents(_ userID: String) async throws -> Incidents {
        let data = try await get("/incidents", ["user_ids[]": userID])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(IncidentsResp.self, from: data)

        return resp.incidents
    }

    func getIncidentsURL() async throws -> URL {
        let user = try await getUser()
        let url = URL(string: user.htmlUrl)!
        let uid = userID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? user.id : userID
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = "/incidents"
        components.query = "assignedToUser=\(uid)"

        return components.url!
    }

    func getOnCallShiftsURL() async throws -> URL {
        let user = try await getUser()
        let url = URL(string: user.htmlUrl)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = "/my-on-call/week"

        return components.url!
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
