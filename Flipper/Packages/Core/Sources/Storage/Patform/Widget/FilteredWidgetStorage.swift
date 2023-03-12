import Peripheral

import Combine

class FilteredWidgetStorage: TodayWidgetKeysStorage {
    private var widgetStorage: TodayWidgetKeysStorage
    private var mobileStorage: ArchiveStorage

    var didChange: AnyPublisher<Void, Never> { widgetStorage.didChange }

    init(widgetStorage: TodayWidgetKeysStorage, mobileStorage: ArchiveStorage) {
        self.widgetStorage = widgetStorage
        self.mobileStorage = mobileStorage
    }

    func read() async throws -> [WidgetKey] {
        let storedKeys = try await widgetStorage.read()
        let manifest = try await mobileStorage.manifest
        return storedKeys.filter { manifest.items[$0.path] != nil }
    }

    func write(_ keys: [WidgetKey]) async throws {
        try await widgetStorage.write(keys)
    }
}
