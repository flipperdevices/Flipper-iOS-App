public protocol PairedDevice {
    var flipper: SafePublisher<Flipper?> { get }
    var isPairingFailed: Bool { get }

    func connect()
    func disconnect()
    func forget()
}
