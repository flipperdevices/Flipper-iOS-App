import Peripheral

class PlainSyncedManifestStorage: SyncedManifestStorage {
    let storage: PlainManifestStorage = .init()
    let filename = "synced_manifest.txt"
    var manifestPath: Path { .init(string: filename) }

    var manifest: Manifest? {
        get {
            try? storage.read(manifestPath)
        }
        set {
            if let manifest = newValue {
                try? storage.write(manifest, at: manifestPath)
            } else {
                try? storage.storage.delete(manifestPath)
            }
        }
    }
}
