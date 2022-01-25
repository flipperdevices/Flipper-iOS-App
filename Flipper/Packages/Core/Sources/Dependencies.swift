import Inject
import Logging

public func registerDependencies() {
    let container = Container.shared

    LoggingSystem.bootstrap(FileLogHandler.factory)
    container.register(JSONLoggerStorage.init, as: LoggerStorage.self, isSingleton: true)

    let central = FlipperCentral()
    container.register(instance: central, as: BluetoothCentral.self)
    container.register(instance: central, as: BluetoothConnector.self)
    container.register(PairedFlipper.init, as: PairedDevice.self, isSingleton: true)
    container.register(MobileArchive.init, as: MobileArchiveProtocol.self, isSingleton: true)
    container.register(FlipperArchive.init, as: PeripheralArchiveProtocol.self, isSingleton: true)
    container.register(Synchronization.init, as: SynchronizationProtocol.self, isSingleton: true)
    container.register(JSONDeviceStorage.init, as: DeviceStorage.self, isSingleton: true)
    container.register(JSONArchiveStorage.init, as: ArchiveStorage.self, isSingleton: true)
    container.register(JSONManifestStorage.init, as: ManifestStorage.self, isSingleton: true)
    container.register(IOSNFCService.init, as: NFCService.self)
}
