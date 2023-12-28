import Peripheral

class SyncedFavorites: FavoritesProtocol {
    let storage: FileStorage = .init()
    let filename = "synced_favorites.txt"
    var path: Path { .init(string: filename) }

    func read() async throws -> Favorites {
        await storage.isExists(path)
            ? try storage.read(path)
            : .init()
    }

    func write(_ favorites: Favorites) async throws {
        try await storage.write(favorites, at: path)
    }
}
