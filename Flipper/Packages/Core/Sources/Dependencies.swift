import Inject

public func registerDependencies() {
    let container = Container.shared
    let central = FlipperCentral()
    container.register(instance: central, as: BluetoothCentral.self)
    container.register(instance: central, as: BluetoothConnector.self)
    container.register(PairedFlipper.init, as: PairedDevice.self, isSingleton: true)
    container.register(FlipperArchive.init, as: PeripheralArchive.self, isSingleton: true)
    container.register(Synchronization.init, as: SynchronizationProtocol.self, isSingleton: true)
    container.register(JSONDeviceStorage.init, as: DeviceStorage.self, isSingleton: true)
    container.register(JSONArchiveStorage.init, as: ArchiveStorage.self, isSingleton: true)
    container.register(JSONManifestStorage.init, as: ManifestStorage.self, isSingleton: true)
    container.register(IOSNFCService.init, as: NFCService.self)
}
