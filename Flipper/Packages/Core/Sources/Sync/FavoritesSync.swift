import Inject
import Peripheral
import OrderedCollections

class FavoritesSync: FavoritesSyncProtocol {
    @Inject private var mobileFavorites: MobileFavoritesProtocol
    @Inject private var flipperFavorites: FlipperFavoritesProtocol
    @Inject private var syncedFavorites: SyncedFavoritesProtocol

    func run() async throws {
        let mobile = try await mobileFavorites.read().paths
        let synced = try await syncedFavorites.read().paths
        let flippers = try await flipperFavorites.read().paths

        let deletedOnMobile = synced.filter { !mobile.contains($0) }
        let deletedOnFlipper = synced.filter { !flippers.contains($0) }

        let actualOnMobile = mobile.filter { !deletedOnFlipper.contains($0) }
        let actualOnFlipper = flippers.filter { !deletedOnMobile.contains($0) }

        let result = OrderedSet<Path>(actualOnMobile)
            .union(OrderedSet<Path>(actualOnFlipper))
        let favorites: Favorites = .init([Path](result))

        try await mobileFavorites.write(favorites)
        try await syncedFavorites.write(favorites)
        try await flipperFavorites.write(favorites)
    }
}
