import Foundation

public class Sharing {
    private init() {}

    enum Error: String, Swift.Error {
        case unsupportedScheme = "unsupported scheme"
        case encodingError = "encoding error"
        case urlIsTooLong = "url is too long"
    }

    private static func importer(for scheme: String?) -> Importer? {
        switch scheme {
        case "https": return WebImporter()
        case "file": return FileImporter()
        case "flipper": return CustomImporter()
        default: return nil
        }
    }

    public static func importKey(from url: URL) async throws -> ArchiveItem {
        guard let importer = importer(for: url.scheme) else {
            throw Error.unsupportedScheme
        }
        return try await importer.importKey(from: url)
    }
}

public func share(_ text: String) {
    share([text])
}

public func share(_ content: String, filename: String) {
    let urls = FileManager.default.urls(
        for: .cachesDirectory, in: .userDomainMask)

    guard let publicDirectory = urls.first else {
        return
    }

    let fileURL = publicDirectory.appendingPathComponent(filename)
    let data = content.data(using: .utf8)

    FileManager.default.createFile(atPath: fileURL.path, contents: data)

    share([fileURL]) {_, _, _, _ in
        try? FileManager.default.removeItem(at: fileURL)
    }
}
