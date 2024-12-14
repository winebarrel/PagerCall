import SwiftUI

struct Incident: Codable, Identifiable {
    let id: String
    let title: String
    let htmlUrl: String
    let service: Service
    let urgency: Urgency
    let createdAt: Date

    struct Service: Codable {
        let summary: String
    }

    enum Urgency: String, Codable {
        case high
        case low
    }
}

typealias Incidents = [Incident]

func - (left: Incidents, right: Incidents) -> Incidents {
    let rightIDs = right.map { $0.id }
    return left.filter { !rightIDs.contains($0.id) }
}

struct PagerDutyAPI {
    private let endpoint = URL(string: "https://api.pagerduty.com/")!

    @AppStorage("userID") private var userID: String = ""

    private struct OncallsResp: Codable {
        let oncalls: [Oncall]
        struct Oncall: Codable {}
    }

    func isOnCall(_ apiKey: String) async throws -> Bool {
        let data = try await get(apiKey, "oncalls", ["user_ids[]": userID])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(OncallsResp.self, from: data)

        return !resp.oncalls.isEmpty
    }

    private struct IncidentsResp: Codable {
        let incidents: Incidents
    }

    func getIncidents(_ apiKey: String) async throws -> Incidents {
        let data = try await get(apiKey, "incidents", ["user_ids[]": userID])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let resp = try decoder.decode(IncidentsResp.self, from: data)

        return resp.incidents
    }

    private func get(_ apiKey: String, _ path: String, _ query: [String: String] = [:]) async throws -> Data {
        var url = endpoint.appending(component: path, directoryHint: .notDirectory)
        url.append(queryItems: query.map { key, val in URLQueryItem(name: key, value: val) })

        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Token token=\(apiKey)", forHTTPHeaderField: "Authorization")

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
