import Inject
import Peripheral
import Foundation

class MobileArchive: MobileArchiveProtocol {
    @Inject var storage: MobileArchiveStorage
    @Inject var manifestStorage: MobileManifestStorage

    var manifest: Manifest {
        get { manifestStorage.manifest ?? .init() }
        set { manifestStorage.manifest = newValue }
    }

    init() {}

    func getManifest(progress: (Double) -> Void) async throws -> Manifest {
        progress(1)
        return manifest
    }

    func read(_ path: Path, progress: (Double) -> Void) async throws -> String {
        try await storage.get(path)
    }

    func upsert(_ content: String, at path: Path, progress: (Double) -> Void) async throws {
        try await storage.upsert(content, at: path)
        manifest[path] = .init(content.md5)
    }

    func delete(_ path: Path) async throws {
        try await storage.delete(path)
        manifest[path] = nil
    }

    func compress() -> URL? {
        storage.compress()
    }
}
