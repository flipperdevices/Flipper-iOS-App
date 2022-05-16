public protocol PairedDevice {
    var flipper: SafePublisher<Flipper?> { get }

    func connect()
    func disconnect()
    func forget()

    func updateStorageInfo(_ storageInfo: Flipper.StorageInfo)
}
