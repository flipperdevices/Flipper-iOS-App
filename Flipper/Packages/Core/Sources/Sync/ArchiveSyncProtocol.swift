import Combine

protocol ArchiveSyncProtocol {
    var events: AnyPublisher<ArchiveSync.Event, Never> { get }

    func run(_ progress: (Synchronization.Progress) -> Void) async throws -> Int
    func cancel()
}
