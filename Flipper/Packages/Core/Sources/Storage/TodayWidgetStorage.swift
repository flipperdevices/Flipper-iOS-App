import Combine

public protocol TodayWidgetKeysStorage {
    func read() async throws -> [WidgetKey]
    func write(_ keys: [WidgetKey]) async throws
}
