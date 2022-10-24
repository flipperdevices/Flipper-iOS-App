import Inject
import Peripheral

class DeletedArchive: DeletedArchiveProtocol {
    @Inject var storage: DeletedArchiveStorage

    init() {}

    func getManifest(
        progress: (Double) -> Void
    ) async throws -> Manifest {
        progress(1)
        return try await storage.manifest
    }

    func read(
        _ path: Path,
        progress: (Double) -> Void
    ) async throws -> String {
        try await storage.get(path)
    }

    func upsert(
        _ content: String,
        at path: Path,
        progress: (Double) -> Void
    ) async throws {
        progress(1)
        try await storage.upsert(content, at: path)
    }

    func delete(_ path: Path) async throws {
        try await storage.delete(path)
    }
}
