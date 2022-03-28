class FlipperFavoritesMock: FlipperFavoritesProtocol {
    func read() async throws -> Favorites { .init() }
    func write(_ favorites: Favorites) async throws { }
}
