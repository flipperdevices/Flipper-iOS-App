import Peripheral

class SyncedFavorites: FavoritesStorage {
    let storage: FileStorage = .init()
    var path: Path = "synced_favorites.txt"

    func read() async throws -> Favorites {
        await storage.isExists(path)
            ? try storage.read(path)
            : .init()
    }

    func write(_ favorites: Favorites) async throws {
        try await storage.write(favorites, at: path)
    }
}
