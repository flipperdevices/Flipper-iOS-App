import Inject
import Bluetooth

class MobileArchive: MobileArchiveProtocol {
    @Inject var storage: MobileArchiveStorage
    @Inject var manifestStorage: MobileManifestStorage

    var manifest: Manifest {
        get { manifestStorage.manifest ?? .init([:]) }
        set { manifestStorage.manifest = newValue }
    }

    init() {}

    func read(_ path: Path) async throws -> String {
        try await storage.get(path)
    }

    func upsert(_ content: String, at path: Path) async throws {
        try await storage.upsert(content, at: path)
        manifest[path] = .init(content.md5)
    }

    func delete(_ path: Path) async throws {
        try await storage.delete(path)
        manifest[path] = nil
    }
}
