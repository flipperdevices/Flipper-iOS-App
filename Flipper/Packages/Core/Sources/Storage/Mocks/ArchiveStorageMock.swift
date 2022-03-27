import Peripheral

public class ArchiveStorageMock: MobileArchiveStorage, DeletedArchiveStorage {
    public var manifest: Manifest { .init([:]) }

    public func get(_ path: Path) async throws -> String {
        fatalError("not implemented")
    }

    public func upsert(_ content: String, at path: Path) async throws {
    }

    public func delete(_ path: Path) async throws {
    }
}
