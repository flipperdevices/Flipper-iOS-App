import Foundation

// MARK: Internal protocol to inherit 'endpoint' property

protocol Endpoint {
    var path: String { get }
    var baseURL: URL { get }
}

extension Endpoint {
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

protocol CatalogRequest: Endpoint, Request {
    var queryItems: [URLQueryItem] { get set }
}

extension CatalogRequest {
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

extension CatalogRequest {
    public func get() async throws -> Result {
        guard !queryItems.isEmpty else {
            return try await object(from: endpoint)
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
        return try await object(from: url)
    }

    private func object(from url: URL) async throws -> Result {
        let data = try await data(from: url)
        // swiftlint:disable force_cast
        guard Result.self != Data.self else {
            return data as! Result
        }
        return try JSONDecoder().decode(Result.self, from: data)
    }

    private func data(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse else {
            throw URLError(.unknown)
        }
        guard response.statusCode == 200 else {
            if let error = try? error(decoding: data) {
                throw CatalogError(
                    httpCode: response.statusCode,
                    serverError: error)
            } else {
                throw URLError(.init(rawValue: response.statusCode))
            }
        }
        return data
    }

    private func error(decoding data: Data) throws -> ServerError {
        do {
            return try JSONDecoder().decode(ServerError.self, from: data)
        } catch {
            logger.error("decoding: \(error)")
            throw error
        }
    }
}
