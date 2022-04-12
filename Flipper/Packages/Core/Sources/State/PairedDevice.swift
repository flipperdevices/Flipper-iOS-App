public protocol PairedDevice {
    var flipper: SafePublisher<Flipper?> { get }

    func connect()
    func disconnect()
    func forget()
}
