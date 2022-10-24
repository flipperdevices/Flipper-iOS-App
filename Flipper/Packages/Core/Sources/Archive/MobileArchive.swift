import Inject
import Peripheral
import Foundation

class MobileArchive: MobileArchiveProtocol {
    @Inject var storage: MobileArchiveStorage

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
        try await storage.upsert(content, at: path)
    }

    func delete(_ path: Path) async throws {
        try await storage.delete(path)
    }

    func compress() -> URL? {
        storage.compress()
    }
}
