import Peripheral
import Foundation
import Logging

class WebImporter: Importer {
    enum Error: Swift.Error {
        case invalidURLFragment
        case invalidQueryEncoding
        case invalidProperties
        case invalidPathKey
        case invalidPath
        case serverError
    }

    func importKey(from url: URL) async throws -> ArchiveItem {
        if url.pathComponents.contains("sf") {
            return try await importKey(serverKey: url)
        } else {
            return try await importKey(shortURL: url)
        }
    }

    func importKey(serverKey url: URL) async throws -> ArchiveItem {
        guard let item = try await TempLinkSharing().importKey(url: url) else {
            throw Error.serverError
        }
        return item
    }

    func importKey(shortURL url: URL) async throws -> ArchiveItem {
        guard let encodedQuery = url.fragment else {
            throw Error.invalidURLFragment
        }
        guard let query = KeyCoder.decode(query: encodedQuery) else {
            throw Error.invalidQueryEncoding
        }
        guard let properties = [ArchiveItem.Property](queryString: query) else {
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

public func makeShareURL(for key: ArchiveItem) throws -> String {
    let baseURL = "https://flpr.app/s#"

    var query: String? {
        let path = "path=\(key.path.string.dropFirst())"
        return KeyCoder.encode(query: "\(path)&\(key.properties.queryString)")
    }

    guard let query = query else {
        throw Sharing.Error.encodingError
    }

    return baseURL + query
}

public func shareAsURL(_ key: ArchiveItem) throws {
    let url = try makeShareURL(for: key)

    guard url.count <= 200 else {
        throw Sharing.Error.urlIsTooLong
    }

    share([url])
}

fileprivate extension Array where Element == ArchiveItem.Property {
    var queryString: String {
        self.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    }

    init?(queryString: String) {
        var properties = [ArchiveItem.Property]()

        for keyValue in queryString.split(separator: "&") {
            let parts = keyValue.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else { return nil }
            properties.append(.init(
                key: String(parts[0].trimmingCharacters(in: .whitespaces)),
                value: String(parts[1].trimmingCharacters(in: .whitespaces))))
        }

        self = properties
    }
}

// MARK: CustomStringConvertible

extension WebImporter.Error: CustomStringConvertible {
    var description: String {
        switch self {
        case .invalidURLFragment: return "invalid url fragment"
        case .invalidQueryEncoding: return "invalid query encoding"
        case .invalidProperties: return "invalid properties"
        case .invalidPathKey: return "invalid path key"
        case .invalidPath: return "invalid path"
        case .serverError: return "server error"
        }
    }
}
