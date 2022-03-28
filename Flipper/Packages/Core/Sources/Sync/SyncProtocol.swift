protocol SyncProtocol {
    var events: SafePublisher<Sync.Event> { get }

    func syncWithDevice() async throws
}
