import Peripheral

class MobileFavorites: FavoritesProtocol {
    let storage: FileStorage = .init()
    let filename = "mobile_favorites.txt"
    var path: Path { .init(string: filename) }

    func read() async throws -> Favorites {
        storage.isExists(path)
            ? try storage.read(path)
            : .init()
    }

    func write(_ favorites: Favorites) async throws {
        try storage.write(favorites, at: path)
    }
}
