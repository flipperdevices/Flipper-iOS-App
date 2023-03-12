import Foundation

class ShortURLExporter: Exporter {
    public func exportKey(_ key: ArchiveItem) throws -> URL {
        guard let url = makeURL(key) else {
            throw ExportError.encodingError
        }

        guard url.isShort else {
            throw ExportError.urlIsTooLong
        }

        return url
    }

    func makeURL(_ key: ArchiveItem) -> URL? {
        var queryItems = [URLQueryItem]()
        queryItems.append(name: "path", value: key.path.string.dropFirst())
        queryItems.append(contentsOf: key.properties.map {
            .init(name: $0.key, value: $0.value)
        })

        var components = URLComponents()
        components.fragment = queryItems.plusPercentEncoded
        return components.url(relativeTo: .shareBaseURL)
    }
}

extension URL {
    public var isShort: Bool {
        absoluteString.count <= 256
    }
}
