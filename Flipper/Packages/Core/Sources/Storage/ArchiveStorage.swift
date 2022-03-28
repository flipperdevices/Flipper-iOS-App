import Peripheral
import Foundation

public protocol ArchiveStorage {
    func get(_ path: Path) async throws -> String
    func upsert(_ content: String, at path: Path) async throws
    func delete(_ path: Path) async throws
}

public protocol MobileArchiveStorage: ArchiveStorage {
    func compress() -> URL?
}
public protocol DeletedArchiveStorage: ArchiveStorage {}
