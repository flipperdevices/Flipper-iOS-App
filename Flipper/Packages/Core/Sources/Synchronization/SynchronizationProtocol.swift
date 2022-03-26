protocol SynchronizationProtocol {
    var events: SafePublisher<Synchronization.Event> { get }

    func syncWithDevice() async throws
    func status(for item: ArchiveItem) async throws -> ArchiveItem.Status
}
