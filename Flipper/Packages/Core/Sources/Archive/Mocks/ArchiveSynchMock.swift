import Combine

class ArchiveSyncMock: ArchiveSyncProtocol {
    var events: AnyPublisher<ArchiveSync.Event, Never> {
        Empty().eraseToAnyPublisher()
    }

    func run(_ progress: (Double) -> Void) {}
}
