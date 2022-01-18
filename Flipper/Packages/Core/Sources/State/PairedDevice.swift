public protocol PairedDevice {
    var peripheral: SafePublisher<Peripheral?> { get }
    var isPairingFailed: Bool { get }

    func connect()
    func disconnect()
    func forget()
}
