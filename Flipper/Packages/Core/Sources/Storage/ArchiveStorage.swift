import Peripheral

public protocol ArchiveStorage {
    var manifest: Manifest { get async throws }

    func get(_ path: Path) async throws -> String
    func upsert(_ content: String, at path: Path) async throws
    func delete(_ path: Path) async throws
}
