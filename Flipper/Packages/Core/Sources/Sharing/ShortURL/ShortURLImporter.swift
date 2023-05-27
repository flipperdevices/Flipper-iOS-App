import Peripheral
import Foundation

class ShortURLImporter: Importer {
    enum Error: Swift.Error {
        case invalidURLFragment
        case invalidPercentEncoding
        case invalidProperties
        case invalidPathKey
        case invalidPath
        case serverError
    }

    func importKey(from url: URL) async throws -> ArchiveItem {
        guard let query = url.fragment else {
            throw Error.invalidURLFragment
        }
        guard let items = [URLQueryItem](plusPercentEncoded: query) else {
            throw Error.invalidPercentEncoding
        }
        guard let properties = [ArchiveItem.Property](queryItems: items) else {
            throw Error.invalidProperties
        }
        guard let path = properties.first, path.key == "path" else {
            throw Error.invalidPathKey
        }
        return try await importKey(
            path: .init(string: path.value),
            properties: .init(properties[1...]))
    }

    private func importKey(
        path: Path,
        properties: [ArchiveItem.Property]
    ) async throws -> ArchiveItem {
        guard let filename = path.lastComponent else {
            throw Error.invalidPath
        }
        return try .init(filename: filename, properties: properties)
    }
}

fileprivate extension Array where Element == ArchiveItem.Property {
    var queryItems: [URLQueryItem] {
        self.map { .init(name: $0.key, value: $0.value) }
    }

    init?(queryItems: [URLQueryItem]) {
        var properties = [ArchiveItem.Property]()

        for queryItem in queryItems {
            guard let value = queryItem.value else {
                return nil
            }
            properties.append(.init(
                key: queryItem.name.trimmingCharacters(in: .whitespaces),
                value: value.trimmingCharacters(in: .whitespaces)))
        }

        self = properties
    }
}

// MARK: CustomStringConvertible

extension ShortURLImporter.Error: CustomStringConvertible {
    var description: String {
        switch self {
        case .invalidURLFragment: return "invalid url fragment"
        case .invalidPercentEncoding: return "invalid percent encoding"
        case .invalidProperties: return "invalid properties"
        case .invalidPathKey: return "invalid path key"
        case .invalidPath: return "invalid path"
        case .serverError: return "server error"
        }
    }
}
