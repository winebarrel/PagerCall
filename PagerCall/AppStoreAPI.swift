import Foundation

struct AppStoreRespResult: Codable {
    var version: String
}

struct AppStoreResp: Codable {
    var results: [AppStoreRespResult]
}

enum AppStoreAPI {
    static func getInfo(_ bundleId: String) async -> AppStoreRespResult? {
        do {
            let req = URLRequest(url: URL(string: "https://itunes.apple.com/br/lookup?bundleId=\(bundleId)")!)
            let (data, rawResp) = try await URLSession.shared.data(for: req)

            guard let resp = rawResp as? HTTPURLResponse else {
                fatalError("failed to cast URLResponse to HTTPURLResponse")
            }

            if resp.statusCode != 200 {
                return nil
            }

            let decoder = JSONDecoder()
            let info = try decoder.decode(AppStoreResp.self, from: data)

            return info.results.first
        } catch {
            Logger.shared.error("AppStore API request error: \(error)")
            return nil
        }
    }
}
