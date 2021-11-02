public protocol PairedDeviceProtocol {
    var peripheral: SafePublisher<Peripheral?> { get }

    func disconnect()

    func send(
        _ request: Request,
        priority: Priority,
        continuation: @escaping Continuation
    )
}
