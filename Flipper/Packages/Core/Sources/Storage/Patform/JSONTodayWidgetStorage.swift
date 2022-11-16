import Peripheral
import Foundation
import Combine

class JSONTodayWidgetStorage: NSObject, TodayWidgetStorage {
    let storage: FileStorage = .init()
    let filename = "today_widget_keys.json"
    var path: Path { .init(string: filename) }

    var didChange: AnyPublisher<Void, Never> {
        didChangeSubject.eraseToAnyPublisher()
    }
    fileprivate let didChangeSubject = PassthroughSubject<Void, Never>()

    var keys: [WidgetKey] {
        get {
            (try? storage.read(path)) ?? []
        }
        set {
            try? storage.write(newValue, at: path)
        }
    }

    override init() {
        super.init()
        NSFileCoordinator.addFilePresenter(self)
    }
}

extension JSONTodayWidgetStorage: NSFilePresenter {
    public var presentedItemURL: URL? {
        return storage.baseURL.appendingPathComponent(filename)
    }

    public var presentedItemOperationQueue: OperationQueue {
        return OperationQueue.main
    }

    public func presentedItemDidChange() {
        didChangeSubject.send(())
    }
}
