import Foundation

protocol Exporter {
    func exportKey(_ item: ArchiveItem) async throws -> URL
}

enum ExportError: String, Swift.Error {
    case unsupportedScheme = "unsupported scheme"
    case encodingError = "encoding error"
    case urlIsTooLong = "url is too long"
}
