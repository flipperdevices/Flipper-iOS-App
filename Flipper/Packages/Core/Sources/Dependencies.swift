import Inject
import Logging
import Peripheral

public func registerDependencies() {
    let container = Container.shared

    LoggingSystem.bootstrap(FileLogHandler.factory)
    container.register(JSONLoggerStorage.init, as: LoggerStorage.self, isSingleton: true)

    Peripheral.registerDependencies()

    // device
    container.register(PairedFlipper.init, as: PairedDevice.self, isSingleton: true)
    // archive
    container.register(MobileArchive.init, as: MobileArchiveProtocol.self, isSingleton: true)
    container.register(DeletedArchive.init, as: DeletedArchiveProtocol.self, isSingleton: true)
    container.register(FlipperArchive.init, as: FlipperArchiveProtocol.self, isSingleton: true)
    // storage
    container.register(JSONDeviceStorage.init, as: DeviceStorage.self, isSingleton: true)
    container.register(PlainMobileArchiveStorage.init, as: MobileArchiveStorage.self, isSingleton: true)
    container.register(PlainDeletedArchiveStorage.init, as: DeletedArchiveStorage.self, isSingleton: true)
    // manifests
    container.register(PlainMobileManifestStorage.init, as: MobileManifestStorage.self, isSingleton: true)
    container.register(PlainDeletedManifestStorage.init, as: DeletedManifestStorage.self, isSingleton: true)
    container.register(PlainSyncedManifestStorage.init, as: SyncedManifestStorage.self, isSingleton: true)
    // sync
    container.register(Sync.init, as: SyncProtocol.self, isSingleton: true)
}
