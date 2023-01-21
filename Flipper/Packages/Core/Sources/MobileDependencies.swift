import Inject
import Logging
import Analytics

import func Peripheral.registerDependencies
import func Peripheral.registerMockDependencies

public func registerMobileDependencies() {
    let container = Container.shared

    LoggingSystem.bootstrap(FileLogHandler.factory)
    container.register(PlainLoggerStorage.init, as: LoggerStorage.self, isSingleton: true)

    AnalyticsSystem.bootstrap([CountlyAnalytics(), ClickhouseAnalytics()])

    #if !targetEnvironment(simulator)
    Peripheral.registerDependencies()
    #else
    Peripheral.registerMockDependencies()
    #endif

    container.register(Archive.init, as: Archive.self, isSingleton: true)
    // device
    container.register(PairedFlipper.init, as: PairedDevice.self, isSingleton: true)
    // archive
    container.register(MobileArchive.init, as: MobileArchiveProtocol.self, isSingleton: true)
    container.register(DeletedArchive.init, as: DeletedArchiveProtocol.self, isSingleton: true)
    container.register(FlipperArchive.init, as: FlipperArchiveProtocol.self, isSingleton: true)
    // storage
    container.register(PlainDeviceStorage.init, as: DeviceStorage.self, isSingleton: true)
    container.register(PlainMobileArchiveStorage.init, as: MobileArchiveStorage.self, isSingleton: true)
    container.register(PlainMobileNotesStorage.init, as: MobileNotesStorage.self, isSingleton: true)
    container.register(PlainDeletedArchiveStorage.init, as: DeletedArchiveStorage.self, isSingleton: true)
    container.register(JSONTodayWidgetStorage.init, as: TodayWidgetStorage.self, isSingleton: true)
    // manifests
    container.register(PlainSyncedItemsStorage.init, as: SyncedItemsProtocol.self, isSingleton: true)
    // favorites
    container.register(MobileFavorites.init, as: MobileFavoritesProtocol.self, isSingleton: true)
    container.register(FlipperFavorites.init, as: FlipperFavoritesProtocol.self, isSingleton: true)
    container.register(SyncedFavorites.init, as: SyncedFavoritesProtocol.self, isSingleton: true)
    // sync
    container.register(ArchiveSync.init, as: ArchiveSyncProtocol.self, isSingleton: true)
    container.register(FavoritesSync.init, as: FavoritesSyncProtocol.self, isSingleton: true)
}
