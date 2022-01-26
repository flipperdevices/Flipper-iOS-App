protocol SynchronizationProtocol {
    var events: SafePublisher<Synchronization.Event> { get }

    func syncWithDevice() async throws
}
