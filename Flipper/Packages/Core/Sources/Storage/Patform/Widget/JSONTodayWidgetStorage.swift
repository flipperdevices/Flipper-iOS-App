import Peripheral

import Combine
import Foundation

class JSONTodayWidgetStorage: NSObject, TodayWidgetKeysStorage {
    let storage: FileStorage = .init()
    let filename = "today_widget_keys.json"
    var path: Path { .init(string: filename) }

    var didChange: AnyPublisher<Void, Never> {
        didChangeSubject.eraseToAnyPublisher()
    }
    fileprivate let didChangeSubject = PassthroughSubject<Void, Never>()

    func read() async throws -> [WidgetKey] {
        do {
            return (try await storage.read(path)) ?? []
        } catch let error as NSError where error.code == 260 {
            return []
        }
    }

    func write(_ keys: [WidgetKey]) async throws {
        try await storage.write(keys, at: path)
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
