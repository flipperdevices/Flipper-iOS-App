protocol FavoritesProtocol {
    func read() async throws -> Favorites
    func write(_ favorites: Favorites) async throws
}
