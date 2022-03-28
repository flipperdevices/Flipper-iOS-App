import Peripheral

class PlainMobileFavoritesStorage: MobileFavoritesStorage {
    let storage: FileStorage = .init()
    let filename = "mobile_favorites.txt"
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
