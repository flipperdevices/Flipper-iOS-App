import Peripheral

class PlainSyncedItemsStorage: SyncedItemsProtocol {
    let storage: FileStorage = .init()
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
                try? storage.delete(manifestPath)
            }
        }
    }
}
