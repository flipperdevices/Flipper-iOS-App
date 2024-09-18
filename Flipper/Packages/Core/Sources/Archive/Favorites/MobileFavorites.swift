import Peripheral

class MobileFavorites: FavoritesStorage {
    let storage: FileStorage = .init()
    var path: Path = "mobile_favorites.txt"

    func read() async throws -> Favorites {
        await storage.isExists(path)
            ? try storage.read(path)
            : .init()
    }

    func write(_ favorites: Favorites) async throws {
        try await storage.write(favorites, at: path)
    }
}
