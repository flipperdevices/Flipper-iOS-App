import Logging
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

public enum SharingMethod {
    case urlOrFile
    case file
}

public func share(_ key: ArchiveItem, as method: SharingMethod = .urlOrFile) {
    do {
        switch method {
        case .urlOrFile: try shareWeb(key)
        case .file: shareFile(key)
        }
    } catch let error as Sharing.Error where error == .urlIsTooLong {
        shareFile(key)
    } catch {
        Logger(label: "Share").error("\(error)")
    }
}

public func share(_ text: String) {
    share([text])
}
