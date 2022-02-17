import Foundation

protocol Importer {
    func importKey(from url: URL) async throws -> ArchiveItem
}
