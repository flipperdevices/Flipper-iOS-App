protocol ArchiveSyncProtocol {
    var events: SafePublisher<ArchiveSync.Event> { get }

    func run() async throws
}
