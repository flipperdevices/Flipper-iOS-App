import Foundation

protocol Importer {
    func importKey(from url: URL) async throws -> ArchiveItem
}

enum ImportError: String, Swift.Error {
    case unsupportedScheme = "unsupported scheme"
    case invalidURL = "invalid url"
}
