import Peripheral
import Foundation

class SyncedItemsMock: SyncedItemsProcotol {
    var manifest: Manifest?
}

public class ArchiveStorageMock: MobileArchiveStorage {
    public var manifest: Manifest { .init() }

    public func get(_ path: Path) async throws -> String {
        fatalError("not implemented")
    }

    public func upsert(_ content: String, at path: Path) async throws {
    }

    public func delete(_ path: Path) async throws {
    }

    public func compress() -> URL? {
        nil
    }
}

class DeletedStorageMock: ArchiveStorageMock, DeletedArchiveStorage {}
class NotesStorageMock: ArchiveStorageMock, MobileNotesStorage {}
