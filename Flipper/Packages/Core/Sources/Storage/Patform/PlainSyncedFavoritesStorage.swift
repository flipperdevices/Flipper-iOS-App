import Peripheral

class PlainSyncedFavoritesStorage: SyncedFavoritesStorage {
    let storage: FileStorage = .init()
    let filename = "synced_favorites.txt"
    var path: Path { .init(string: filename) }

    var favorites: Favorites? {
        get {
            try? storage.read(path)
        }
        set {
            if let manifest = newValue {
                try? storage.write(manifest, at: path)
            } else {
                try? storage.delete(path)
            }
        }
    }
}
