import Core
import Combine
import Foundation

class WidgetSettingsViewModel: ObservableObject {
    private var container: UserDefaults? { .widget }

    private var archive: Archive { AppState.shared.archive }
    private var disposeBag: DisposeBag = .init()

    @Published var keys: [WidgetKey] = [] {
        didSet {
            container?.keys = keys
            container?.synchronize()
        }
    }
    @Published var showAddKeyView = false

    init() {
        self.keys = container?.keys ?? []
        archive.$items
            .receive(on: DispatchQueue.main)
            .sink { items in
                self.keys = self.keys.filter(items.contains)
            }
            .store(in: &disposeBag)
    }

    func delete(at index: Int) {
        keys.remove(at: index)
    }

    func showAddKey() {
        showAddKeyView = true
    }

    func addKey(_ key: ArchiveItem) {
        keys.append(.init(name: key.name, kind: key.kind))
    }
}

extension Array where Element == ArchiveItem {
    func contains(widgetKey: WidgetKey) -> Bool {
        contains { $0.name == widgetKey.name && $0.kind == widgetKey.kind }
    }
}
