import Peripheral
import Foundation

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

class DeletedManifestStorageMock: DeletedManifestStorage {
    var manifest: Manifest?
}
class MobileManifestStorageMock: MobileManifestStorage {
    var manifest: Manifest?
}
class SyncedManifestStorageMock: SyncedManifestStorage {
    var manifest: Manifest?
}

class DeletedStorageMock: ArchiveStorageMock, DeletedArchiveStorage {}
