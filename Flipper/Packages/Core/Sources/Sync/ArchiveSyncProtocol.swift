import Combine

protocol ArchiveSyncProtocol {
    var events: AnyPublisher<ArchiveSync.Event, Never> { get }

    func run(_ progress: (Double) -> Void) async throws -> Int
    func cancel()
}
