import Inject
import Logging
import Peripheral

public func registerMockDependencies() {
    let container = Container.shared

    LoggingSystem.bootstrap(FileLogHandler.factory)
    container.register(LoggerStorageMock.init, as: LoggerStorage.self, isSingleton: true)

    Peripheral.registerMockDependencies()

    // device
    container.register(PairedFlipper.init, as: PairedDevice.self, isSingleton: true)
    // archive
    container.register(MobileArchiveMock.init, as: MobileArchiveProtocol.self, isSingleton: true)
    container.register(DeletedArchiveMock.init, as: DeletedArchiveProtocol.self, isSingleton: true)
    container.register(FlipperArchiveMock.init, as: FlipperArchiveProtocol.self, isSingleton: true)
    // storage
    container.register(DeviceStorageMock.init, as: DeviceStorage.self, isSingleton: true)
    container.register(ArchiveStorageMock.init, as: MobileArchiveStorage.self, isSingleton: true)
    container.register(ArchiveStorageMock.init, as: DeletedArchiveStorage.self, isSingleton: true)
    // manifests
    container.register(MobileManifestStorageMock.init, as: MobileManifestStorage.self, isSingleton: true)
    container.register(DeletedManifestStorageMock.init, as: DeletedManifestStorage.self, isSingleton: true)
    container.register(SyncedManifestStorageMock.init, as: SyncedManifestStorage.self, isSingleton: true)
    // favorites
    container.register(MobileFavoritesMock.init, as: MobileFavoritesProtocol.self, isSingleton: true)
    container.register(FlipperFavoritesMock.init, as: FlipperFavoritesProtocol.self, isSingleton: true)
    container.register(SyncedFavoritesMock.init, as: SyncedFavoritesProtocol.self, isSingleton: true)
    // sync
    container.register(ArchiveSyncMock.init, as: ArchiveSyncProtocol.self, isSingleton: true)
    container.register(FavoritesSyncMock.init, as: FavoritesSyncProtocol.self, isSingleton: true)
}
