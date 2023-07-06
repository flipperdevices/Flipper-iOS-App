import Foundation

public class AppVersionCheck {
    private static var baseURL: String {
        "https://itunes.apple.com/lookup"
    }

    struct Response: Decodable {
        let results: [Result]

        struct Result: Decodable {
            let version: String
        }
    }

    public static var hasUpdate: Bool {
        get async {
            guard
                Bundle.isAppStoreBuild,
                let bundleID = Bundle.id,
                let currentVersion = Bundle.shortVersion,
                let url = URL(string: "\(baseURL)?bundleId=\(bundleID)")
            else {
                return false
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder()
                    .decode(Response.self, from: data)
                guard let result = response.results.first else {
                    logger.error("app version check: empty response")
                    return false
                }
                return result.version != currentVersion
            } catch {
                logger.error("app version check: \(error)")
                return false
            }
        }
    }
}
