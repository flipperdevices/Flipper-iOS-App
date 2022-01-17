public protocol PairedDevice {
    var peripheral: SafePublisher<Peripheral?> { get }

    func connect()
    func disconnect()
    func forget()
}
