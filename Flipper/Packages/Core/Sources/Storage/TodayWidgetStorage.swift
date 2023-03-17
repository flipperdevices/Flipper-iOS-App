import Combine

public protocol TodayWidgetKeysStorage {
    var didChange: AnyPublisher<Void, Never> { get }

    func read() async throws -> [WidgetKey]
    func write(_ keys: [WidgetKey]) async throws
}
