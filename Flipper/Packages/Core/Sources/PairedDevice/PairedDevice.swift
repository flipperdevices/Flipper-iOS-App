import Peripheral

public protocol PairedDevice {
    var session: Session { get }
    var flipper: SafePublisher<Flipper?> { get }

    func connect()
    func disconnect()
    func forget()

    func updateStorageInfo(_ storageInfo: Flipper.StorageInfo)
}

