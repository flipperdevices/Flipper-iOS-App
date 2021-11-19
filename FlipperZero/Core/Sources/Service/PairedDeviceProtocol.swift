public protocol PairedDeviceProtocol {
    var peripheral: SafePublisher<Peripheral?> { get }

    func disconnect()

    func send(_ request: Request, priority: Priority) async throws -> Response
}
