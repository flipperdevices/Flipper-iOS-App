import Combine

class SynchronizationMock: SynchronizationProtocol {
    var events: AnyPublisher<Synchronization.Event, Never> {
        Empty().eraseToAnyPublisher()
    }

    func syncWithDevice() {}
    func status(for item: ArchiveItem) -> ArchiveItem.Status { .synchronized }
}
