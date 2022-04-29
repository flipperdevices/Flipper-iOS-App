protocol ArchiveSyncProtocol {
    var events: SafePublisher<ArchiveSync.Event> { get }

    func run(_ progress: (Double) -> Void) async throws
}
