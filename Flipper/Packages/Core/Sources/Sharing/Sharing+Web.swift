import Foundation

extension Sharing {
    func importWeb(_ url: URL) async throws {
        guard let encodedQuery = url.fragment else {
            logger.error("invalid url fragment")
            return
        }
        guard let query = encodedQuery.removingPercentEncoding else {
            logger.error("invalid query encoding")
            return
        }
        guard let properties = [ArchiveItem.Property](queryString: query) else {
            logger.error("invalid properties")
            return
        }
        guard let path = properties.first, path.key == "path" else {
            logger.error("invalid path key")
            return
        }
        try await importKey(
            path: .init(string: path.value),
            properties: .init(properties[1...]))
    }

    private func importKey(
        path: Path,
        properties: [ArchiveItem.Property]
    ) async throws {
        guard let fileName = path.components.last else {
            logger.error("invalid path: \(path)")
            return
        }
        guard let name = ArchiveItem.Name(fileName: fileName) else {
            logger.error("invalid file name: \(fileName)")
            return
        }
        guard let type = ArchiveItem.FileType(fileName: fileName) else {
            logger.error("invalid file type: \(fileName)")
            return
        }
        try await appState.importKey(.init(
            name: name,
            fileType: type,
            properties: properties))
    }
}

public func shareWeb(_ key: ArchiveItem) {
    let baseURL = "https://dev.flpr.app/s#"

    var query: String? {
        "path=\(key.path)&\(key.properties.queryString)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    guard let query = query else {
        print("can't encode key")
        return
    }

    share([baseURL + query])
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
