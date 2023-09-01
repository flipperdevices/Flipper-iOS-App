import Foundation

class CentryClient {
    struct Response: Codable {
        let id: String
    }

    enum Error: Swift.Error {
        case keyNotFound
    }

    private var apiURL: URL {
        "https://sentry.flipperdevices.com/api/3/envelope/"
    }

    private var sentryKey: String? {
        #if DEBUG
        ProcessInfo().environment["SENTRY_KEY"]
        #else
        Bundle.main.object(forInfoDictionaryKey: "SENTRY_KEY") as? String
        #endif
    }

    func capture(_ event: Feedback.Event) async throws -> Response {
        guard let sentryKey else {
            throw Error.keyNotFound
        }
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.contentType = "application/x-sentry-envelope"
        request.xCentryAuth = "Sentry sentry_key=\(sentryKey)"
        request.httpBody = .init(event.encode().utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

private extension URLRequest {
    var contentType: String? {
        get { value(forHTTPHeaderField: "Content-Type") }
        set { setValue(newValue, forHTTPHeaderField: "Content-Type") }
    }

    var xCentryAuth: String? {
        get { value(forHTTPHeaderField: "X-Sentry-Auth") }
        set { setValue(newValue, forHTTPHeaderField: "X-Sentry-Auth") }
    }
}
