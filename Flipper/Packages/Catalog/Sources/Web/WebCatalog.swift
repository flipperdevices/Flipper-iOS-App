import Foundation

public class WebCatalog: CatalogService {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func featured() -> FeaturedRequest {
        .init(baseURL: baseURL)
    }

    public func categories() -> CategoriesRequest {
        .init(baseURL: baseURL)
    }

    public func category(_ id: String) -> CategoryRequest {
        .init(baseURL: baseURL, uid: id)
    }

    public func applications() -> ApplicationsRequest {
        .init(baseURL: baseURL)
    }

    public func application(uid: String) -> ApplicationRequest {
        .init(baseURL: baseURL, uid: uid)
    }

    public func build(forVersionID uid: String) -> BuildRequest {
        .init(baseURL: baseURL, uid: uid)
    }

    // TODO:
    public func report(uid: String, description: String) async throws {
        let url = baseURL.appendingPathComponent("application/\(uid)/issue")
        var request = URLRequest(url: url)

        struct IssueDetails: Codable {
            let description: String
            let descriptionType: String

            enum CodingKeys: String, CodingKey {
                case description
                case descriptionType = "description_type"
            }
        }

        let details = IssueDetails(
            description: description,
            descriptionType: "iOS")

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(details)
        request.httpMethod = "POST"

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw URLError(.badServerResponse)
        }
        guard statusCode == 200 else {
            logger.error("report issue: invalid status code - \(statusCode)")
            logger.debug("response: \(String(decoding: data, as: UTF8.self))")
            return
        }
    }
}
