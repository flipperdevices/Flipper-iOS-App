import Combine

public class TodayWidgetStorageMock: TodayWidgetStorage {
    public var didChange: SafePublisher<Void> {
        Just(()).eraseToAnyPublisher()
    }

    public var keys: [WidgetKey] = []
}
