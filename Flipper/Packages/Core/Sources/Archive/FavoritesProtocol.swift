protocol FavoritesProtocol {
    func read() async throws -> Favorites
    func write(_ favorites: Favorites) async throws
}

protocol MobileFavoritesProtocol: FavoritesProtocol {}
protocol FlipperFavoritesProtocol: FavoritesProtocol {}
protocol SyncedFavoritesProtocol: FavoritesProtocol {}
