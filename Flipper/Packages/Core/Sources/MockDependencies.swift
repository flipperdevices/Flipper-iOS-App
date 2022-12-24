import Inject
import Logging

import func Analytics.registerMockDependencies
import func Peripheral.registerMockDependencies

public func registerMockDependencies() {
    let container = Container.shared

    LoggingSystem.bootstrap(FileLogHandler.factory)
    container.register(LoggerStorageMock.init, as: LoggerStorage.self, isSingleton: true)

    Analytics.registerMockDependencies()
    Peripheral.registerMockDependencies()

    container.register(AppState.init, as: AppState.self, isSingleton: true)
    container.register(Archive.init, as: Archive.self, isSingleton: true)
    // device
    container.register(PairedFlipper.init, as: PairedDevice.self, isSingleton: true)
    // archive
    container.register(MobileArchiveMock.init, as: MobileArchiveProtocol.self, isSingleton: true)
    container.register(DeletedArchiveMock.init, as: DeletedArchiveProtocol.self, isSingleton: true)
    container.register(FlipperArchiveMock.init, as: FlipperArchiveProtocol.self, isSingleton: true)
    // storage
    container.register(DeviceStorageMock.init, as: DeviceStorage.self, isSingleton: true)
    container.register(ArchiveStorageMock.init, as: MobileArchiveStorage.self, isSingleton: true)
    container.register(NotesStorageMock.init, as: MobileNotesStorage.self, isSingleton: true)
    container.register(DeletedStorageMock.init, as: DeletedArchiveStorage.self, isSingleton: true)
    container.register(TodayWidgetStorageMock.init, as: TodayWidgetStorage.self, isSingleton: true)
    // manifests
    container.register(SyncedItemsMock.init, as: SyncedItemsProcotol.self, isSingleton: true)
    // favorites
    container.register(MobileFavoritesMock.init, as: MobileFavoritesProtocol.self, isSingleton: true)
    container.register(FlipperFavoritesMock.init, as: FlipperFavoritesProtocol.self, isSingleton: true)
    container.register(SyncedFavoritesMock.init, as: SyncedFavoritesProtocol.self, isSingleton: true)
    // sync
    container.register(ArchiveSyncMock.init, as: ArchiveSyncProtocol.self, isSingleton: true)
    container.register(FavoritesSyncMock.init, as: FavoritesSyncProtocol.self, isSingleton: true)
}
