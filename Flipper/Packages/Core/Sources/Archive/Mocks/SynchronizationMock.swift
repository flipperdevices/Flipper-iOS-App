import Combine

class SynchronizationMock: SynchronizationProtocol {
    var events: AnyPublisher<Synchronization.Event, Never> {
        Empty().eraseToAnyPublisher()
    }

    func syncWithDevice() async throws {}
}
