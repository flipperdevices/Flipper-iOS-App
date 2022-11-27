import Inject
import Peripheral

import Logging
import Combine
import Foundation

public class WidgetService: ObservableObject {
    private let logger = Logger(label: "widget-service")

    @Inject private var archive: Archive
    @Inject private var storage: TodayWidgetStorage
    private var disposeBag = DisposeBag()

    @Published public private(set) var keys: [WidgetKey] = [] {
        didSet {
            storage.keys = keys
        }
    }

    public init() {
        keys = storage.keys

        archive.items
            .receive(on: DispatchQueue.main)
            .sink { items in
                self.keys = self.keys.filter(items.contains)
            }
            .store(in: &disposeBag)
    }

    public func add(_ key: ArchiveItem) {
        keys.append(.init(name: key.name, kind: key.kind))
    }

    public func delete(at index: Int) {
        keys.remove(at: index)
    }
}

extension Array where Element == ArchiveItem {
    func contains(widgetKey: WidgetKey) -> Bool {
        contains { $0.name == widgetKey.name && $0.kind == widgetKey.kind }
    }
}
