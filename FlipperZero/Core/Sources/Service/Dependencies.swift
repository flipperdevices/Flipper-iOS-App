import Injector

public func registerDependencies() {
    let container = Container.shared
    container.register(BluetoothService.init, as: BluetoothCentral.self, isSingleton: true)
    container.register(BluetoothService.init, as: BluetoothConnector.self, isSingleton: true)
    container.register(PairedDevice.init, as: PairedDeviceProtocol.self, isSingleton: true)
    container.register(NFCService.init, as: NFCServiceProtocol.self, isSingleton: false)
    container.register(JSONDeviceStorage.init, as: DeviceStorage.self, isSingleton: true)
    container.register(JSONArchiveStorage.init, as: ArchiveStorage.self, isSingleton: true)
}
