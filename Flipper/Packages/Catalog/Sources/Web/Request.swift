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
    func append(queryItem: URLQueryItem) -> Self {
        var request = self
        if let index = request.queryItems.firstIndex(where: {
            $0.name == queryItem.name
        }) {
            request.queryItems[index] = queryItem
        } else {
            request.queryItems.append(queryItem)
        }
        return request
    }

    func setQueryItem(name: String, value: String) -> Self {
        append(queryItem: .init(name: name, value: value))
    }

    func setQueryItem(name: String, value: [String]) -> Self {
        setQueryItem(name: name, value: value.joined(separator: ","))
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
        print(url)
        return try await object(from: url)
    }

    private func object(from url: URL) async throws -> Result {
        let data = try await data(from: url)
        return try JSONDecoder().decode(Result.self, from: data)
    }

    private func data(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse else {
            throw URLError(.unknown)
        }
        guard response.statusCode == 200 else {
            print(response.statusCode)
            throw URLError(.init(rawValue: response.statusCode))
        }
        print(String(decoding: data, as: UTF8.self))
        return data
    }
}
