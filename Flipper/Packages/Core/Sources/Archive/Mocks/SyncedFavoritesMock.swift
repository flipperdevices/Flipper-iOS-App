class SyncedFavoritesMock: SyncedFavoritesProtocol {
    func read() async throws -> Favorites { .init() }
    func write(_ favorites: Favorites) async throws { }
}
