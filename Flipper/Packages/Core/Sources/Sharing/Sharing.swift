import Logging
import Foundation

public class Sharing {
    private init() {}

    enum Error: String, Swift.Error {
        case unsupportedScheme = "unsupported scheme"
        case encodingError = "encoding error"
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

public func share(_ key: ArchiveItem) {
    do {
        try shareWeb(key)
    } catch {
        Logger(label: "Share").error("\(error)")
    }
}
