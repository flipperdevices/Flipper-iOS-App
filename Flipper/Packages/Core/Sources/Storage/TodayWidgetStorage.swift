public protocol TodayWidgetStorage {
    var didChange: SafePublisher<Void> { get }
    var keys: [WidgetKey] { get set }
}
