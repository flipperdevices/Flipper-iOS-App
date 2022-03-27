import Inject
import Logging
import Bluetooth

public func registerMockDependencies() {
    let container = Container.shared

    LoggingSystem.bootstrap(FileLogHandler.factory)
    container.register(LoggerStorageMock.init, as: LoggerStorage.self, isSingleton: true)

    Bluetooth.registerMockDependencies()

    container.register(PairedFlipper.init, as: PairedDevice.self, isSingleton: true)
    container.register(MobileArchiveMock.init, as: MobileArchiveProtocol.self, isSingleton: true)
    container.register(DeletedArchiveMock.init, as: DeletedArchiveProtocol.self, isSingleton: true)
    container.register(FlipperArchiveMock.init, as: FlipperArchiveProtocol.self, isSingleton: true)
    container.register(SyncMock.init, as: SyncProtocol.self, isSingleton: true)
    container.register(DeviceStorageMock.init, as: DeviceStorage.self, isSingleton: true)
    container.register(ArchiveStorageMock.init, as: ArchiveStorage.self, isSingleton: true)
    container.register(DeletedStorageMock.init, as: DeletedStorage.self, isSingleton: true)
    container.register(MobileManifestStorageMock.init, as: MobileManifestStorage.self, isSingleton: true)
    container.register(SyncedManifestStorageMock.init, as: SyncedManifestStorage.self, isSingleton: true)
}
