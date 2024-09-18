import Foundation

// MARK: Internal protocol to inherit 'endpoint' property

public protocol Endpoint {
    var path: String { get }
    var baseURL: URL { get }
}

public extension Endpoint {
    var endpoint: URL {
        baseURL.appendingPathComponent(path)
    }
}

// MARK: Pulic protocol to export inherited 'get' function

public protocol Request {
    associatedtype Result: Decodable

    func get() async throws -> Result
}

// MARK: Internal protocol to inherit 'append' and 'get' functions

public protocol BackendRequest: Endpoint, Request {
    var queryItems: [URLQueryItem] { get set }

    var method: String? { get }
    var body: Encodable? { get }

    func getError(data: Data, response: HTTPURLResponse) -> Swift.Error
}

public extension BackendRequest {
    var method: String? { nil }
    var body: Encodable? { nil }
}

public extension BackendRequest {
    func setQueryItem(name: String, value: String) -> Self {
        var request = self
        request.queryItems.append(.init(name: name, value: value))
        return request
    }

    func setQueryItem(name: String, value: [String]) -> Self {
        var result = self
        for item in value {
            result.queryItems.append(.init(name: name, value: item))
        }
        return result
    }

    func setQueryItem(name: String, value: Bool) -> Self {
        setQueryItem(name: name, value: "\(value)")
    }

    func setQueryItem(name: String, value: Int) -> Self {
        setQueryItem(name: name, value: "\(value)")
    }

    func setQueryItem<Value: RawRepresentable>(
        name: String,
        value: Value
    ) -> Self where Value.RawValue == String {
        setQueryItem(name: name, value: value.rawValue)
    }

    func setQueryItem<Value: RawRepresentable>(
        name: String,
        value: Value
    ) -> Self where Value.RawValue == Int {
        setQueryItem(name: name, value: value.rawValue)
    }

    func setQueryItem<Value: RawRepresentable>(
        name: String,
        value: Value
    ) -> Self where Value.RawValue == Bool {
        setQueryItem(name: name, value: value.rawValue)
    }
}

public extension BackendRequest {
    func get() async throws -> Result {
        var request = URLRequest(url: try makeURL())
        if let method {
            request.httpMethod = method
        }
        if let body {
            request.contentType = "application/json"
            request.httpBody = try JSONEncoder().encode(body)
        }
        return try await object(for: request)
    }

    private func makeURL() throws -> URL {
        guard !queryItems.isEmpty else {
            return endpoint
        }
        guard var components = URLComponents(
            url: endpoint,
            resolvingAgainstBaseURL: false
        ) else {
            throw URLError(.badURL)
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }

    private func object(for request: URLRequest) async throws -> Result {
        let data = try await data(for: request)
        switch data {
        case let data as Result: return data
        default: return try JSONDecoder().decode(Result.self, from: data)
        }
    }

    private func data(for request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw URLError(.unknown)
        }
        guard response.statusCode == 200 else {
            throw getError(data: data, response: response)
        }
        return data
    }
}

private extension URLRequest {
    var contentType: String? {
        get { value(forHTTPHeaderField: "Content-Type") }
        set { setValue(newValue, forHTTPHeaderField: "Content-Type") }
    }
}

public extension URLQueryItem {
    init(name: String, value: Int) {
        self.init(name: name, value: "\(value)")
    }
}
