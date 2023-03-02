import Foundation

public class Sharing {
    private init() {}

    public enum Kind {
        case url
        case file
        case server
        case customURL
    }

    private static func kind(of url: URL) -> Kind? {
        switch url.scheme {
        case "file": return .file
        case "flipper": return .customURL
        case "https" where url.isShortURL: return .url
        case "https" where url.isServerFile: return .server
        default: return nil
        }
    }

    private static func importer(for url: URL) -> Importer? {
        switch kind(of: url) {
        case .url: return ShortURLImporter()
        case .server: return ServerFileImporter()
        case .file: return FileImporter()
        case .customURL: return CustomImporter()
        default: return nil
        }
    }

    private static func exporter(for kind: Kind) -> Exporter? {
        switch kind {
        case .url: return ShortURLExporter()
        case .server: return ServerFileExporter()
        case .file: return FileExporter()
        case .customURL: return CustomExporter()
        }
    }

    public static func importKey(from url: URL) async throws -> ArchiveItem {
        guard let importer = importer(for: url) else {
            throw ImportError.unsupportedScheme
        }
        return try await importer.importKey(from: url)
    }

    public static func exportKey(
        _ item: ArchiveItem,
        using kind: Kind
    ) async throws -> URL {
        guard let exporter = exporter(for: kind) else {
            throw ExportError.unsupportedScheme
        }
        return try await exporter.exportKey(item)
    }
}

fileprivate extension URL {
    var isShortURL: Bool {
        pathComponents.contains("s")
    }

    var isServerFile: Bool {
        pathComponents.contains("sf")
    }
}
