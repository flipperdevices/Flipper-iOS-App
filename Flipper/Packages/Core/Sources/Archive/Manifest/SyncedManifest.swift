import Peripheral

class SyncedManifest: ManifestStorage {
    private let storage: FileStorage = .init()
    private let filename = "synced_manifest.txt"
    private var manifestPath: Path { .init(string: filename) }

    func get() async throws -> Manifest {
        await storage.isExists(manifestPath)
            ? try storage.read(manifestPath)
            : .init()

    }

    func upsert(_ manifest: Manifest) async throws {
        try await storage.write(manifest, at: manifestPath)
    }

    func delete() async throws {
        try await storage.delete(manifestPath)
    }
}
