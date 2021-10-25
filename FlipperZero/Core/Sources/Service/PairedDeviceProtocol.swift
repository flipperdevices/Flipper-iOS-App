public protocol PairedDeviceProtocol {
    var peripheral: SafePublisher<Peripheral?> { get }

    func disconnect()
    func send(_ request: Request, continuation: @escaping (Response) -> Void)
}
