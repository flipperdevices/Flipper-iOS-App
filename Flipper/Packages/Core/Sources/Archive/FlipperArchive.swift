import Peripheral

class FlipperArchive: ArchiveProtocol {
    private let storage: StorageAPI

    init(storage: StorageAPI) {
        self.storage = storage
    }

    func getManifest(progress: (Double) -> Void) async throws -> Manifest {
        try await storage.getManifest(progress: progress)
    }

    func read(_ path: Path, progress: (Double) -> Void) async throws -> String {
        try await storage.read(at: path, progress: progress)
    }

    func upsert(
        _ content: String,
        at path: Path,
        progress: (Double) -> Void
    ) async throws {
        try await storage.write(at: path, string: content, progress: progress)
    }

    func delete(_ path: Path) async throws {
        try await storage.delete(at: path)
    }
}
