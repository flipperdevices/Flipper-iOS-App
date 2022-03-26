protocol SyncProtocol {
    var events: SafePublisher<Sync.Event> { get }

    func syncWithDevice() async throws
    func status(for item: ArchiveItem) async throws -> ArchiveItem.Status
}
