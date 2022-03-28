protocol FavoritesStorage {
    var favorites: Favorites? { get set }
}

protocol MobileFavoritesStorage: FavoritesStorage {}
protocol SyncedFavoritesStorage: FavoritesStorage {}
