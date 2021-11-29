import Injector

public func registerDependencies() {
    let container = Container.shared
    container.register(FlipperCentral.init, as: BluetoothCentral.self, isSingleton: true)
    container.register(FlipperCentral.init, as: BluetoothConnector.self, isSingleton: true)
    container.register(PairedFlipper.init, as: PairedDevice.self, isSingleton: true)
    container.register(IOSNFCService.init, as: NFCService.self, isSingleton: false)
    container.register(JSONDeviceStorage.init, as: DeviceStorage.self, isSingleton: true)
    container.register(JSONArchiveStorage.init, as: ArchiveStorage.self, isSingleton: true)
}
