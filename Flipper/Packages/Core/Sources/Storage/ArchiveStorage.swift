import Peripheral
import Foundation

public protocol ArchiveStorage {
    var manifest: Manifest { get async throws }

    func get(_ path: Path) async throws -> String
    func upsert(_ content: String, at path: Path) async throws
    func delete(_ path: Path) async throws
}

public protocol MobileArchiveStorage: ArchiveStorage {
    func compress() -> URL?
}
public protocol MobileNotesStorage: ArchiveStorage {}
public protocol DeletedArchiveStorage: ArchiveStorage {}
