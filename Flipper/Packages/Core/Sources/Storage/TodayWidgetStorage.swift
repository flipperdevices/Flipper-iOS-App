import Combine

public protocol TodayWidgetStorage {
    var didChange: AnyPublisher<Void, Never> { get }
    var keys: [WidgetKey] { get set }
}
