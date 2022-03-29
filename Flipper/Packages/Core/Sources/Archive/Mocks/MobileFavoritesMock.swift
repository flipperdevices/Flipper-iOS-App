class MobileFavoritesMock: MobileFavoritesProtocol {
    func read() async throws -> Favorites { .init() }
    func write(_ favorites: Favorites) async throws { }
}
