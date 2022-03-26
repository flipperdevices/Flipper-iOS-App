import Combine

class SyncMock: SyncProtocol {
    var events: AnyPublisher<Sync.Event, Never> {
        Empty().eraseToAnyPublisher()
    }

    func syncWithDevice() {}
    func status(for item: ArchiveItem) -> ArchiveItem.Status { .synchronized }
}
