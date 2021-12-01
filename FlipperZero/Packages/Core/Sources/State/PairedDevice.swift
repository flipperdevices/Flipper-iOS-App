public protocol PairedDevice {
    var peripheral: SafePublisher<Peripheral?> { get }

    func disconnect()
}
