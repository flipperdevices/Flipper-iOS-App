import Peripheral
import OrderedCollections

class FavoritesSync: FavoritesSyncProtocol {
    private let mobileFavorites: MobileFavoritesProtocol
    private let flipperFavorites: FlipperFavoritesProtocol
    private let syncedFavorites: SyncedFavoritesProtocol

    init(
        mobileFavorites: MobileFavoritesProtocol,
        flipperFavorites: FlipperFavoritesProtocol,
        syncedFavorites: SyncedFavoritesProtocol
    ) {
        self.mobileFavorites = mobileFavorites
        self.flipperFavorites = flipperFavorites
        self.syncedFavorites = syncedFavorites
    }

    func run() async throws {
        let mobile = try await mobileFavorites.read().paths
        let synced = try await syncedFavorites.read().paths
        let flippers = try await flipperFavorites.read().paths

        let deletedOnMobile = synced.filter { !mobile.contains($0) }
        let deletedOnFlipper = synced.filter { !flippers.contains($0) }

        let actualOnMobile = mobile.filter { !deletedOnFlipper.contains($0) }
        let actualOnFlipper = flippers.filter { !deletedOnMobile.contains($0) }

        let result = OrderedSet<Path>(actualOnFlipper)
            .union(OrderedSet<Path>(actualOnMobile))
        let favorites: Favorites = .init([Path](result))

        try await mobileFavorites.write(favorites)
        try await syncedFavorites.write(favorites)
        try await flipperFavorites.write(favorites)
    }
}
