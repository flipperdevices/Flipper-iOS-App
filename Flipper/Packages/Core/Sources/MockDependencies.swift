import Inject
import Logging

public func registerMockDependencies() {
    let container = Container.shared

    LoggingSystem.bootstrap(FileLogHandler.factory)
    container.register(LoggerStorageMock.init, as: LoggerStorage.self, isSingleton: true)

    let central = BluetoothCentralMock(status: .notReady(.preparing))
    container.register(instance: central, as: BluetoothCentral.self)
    container.register(instance: central, as: BluetoothConnector.self)
    container.register(PairedFlipper.init, as: PairedDevice.self, isSingleton: true)
    container.register(PeripheralArchiveMock.init, as: PeripheralArchiveProtocol.self, isSingleton: true)
    container.register(MobileArchiveMock.init, as: MobileArchiveProtocol.self, isSingleton: true)
    container.register(SynchronizationMock.init, as: SynchronizationProtocol.self, isSingleton: true)
    container.register(DeviceStorageMock.init, as: DeviceStorage.self, isSingleton: true)
    container.register(ArchiveStorageMock.init, as: ArchiveStorage.self, isSingleton: true)
    container.register(ManifestStorageMock.init, as: ManifestStorage.self, isSingleton: true)
    container.register(NFCServiceMock.init, as: NFCService.self)
}
