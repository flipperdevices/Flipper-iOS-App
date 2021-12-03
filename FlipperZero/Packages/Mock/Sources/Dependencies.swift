import Inject
@testable import Core

public func registerMockDependencies() {
    let container = Container.shared
    let central = BluetoothCentralMock(status: .notReady(.preparing))
    container.register(instance: central, as: BluetoothCentral.self)
    container.register(instance: central, as: BluetoothConnector.self)
    container.register(PairedFlipper.init, as: PairedDevice.self, isSingleton: true)
    container.register(DeviceStorageMock.init, as: DeviceStorage.self, isSingleton: true)
    container.register(ArchiveStorageMock.init, as: ArchiveStorage.self, isSingleton: true)
    container.register(NFCServiceMock.init, as: NFCService.self)
}
