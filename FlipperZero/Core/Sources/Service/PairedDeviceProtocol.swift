public protocol PairedDeviceProtocol {
    var peripheral: SafePublisher<Peripheral?> { get }

    func disconnect()
}
