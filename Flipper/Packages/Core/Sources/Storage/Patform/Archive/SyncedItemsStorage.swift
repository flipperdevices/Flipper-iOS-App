import Peripheral

class SyncedItemsStorage: ManifestStorage {
    private let storage: FileStorage = .init()
    private let filename = "synced_manifest.txt"
    private var manifestPath: Path { .init(string: filename) }

    func get() async throws -> Manifest {
        storage.isExists(manifestPath)
            ? try storage.read(manifestPath)
            : .init()

    }

    func upsert(_ manifest: Manifest) async throws {
        try storage.write(manifest, at: manifestPath)
    }

    func delete() async throws {
        try storage.delete(manifestPath)
    }
}
