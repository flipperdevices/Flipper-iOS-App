import Combine

class SynchronizationMock: SynchronizationProtocol {
    var events: AnyPublisher<Synchronization.Event, Never> {
        Just(.deleted(.init(path: "/"))).eraseToAnyPublisher()
    }

    func syncWithDevice() async throws {}
}
