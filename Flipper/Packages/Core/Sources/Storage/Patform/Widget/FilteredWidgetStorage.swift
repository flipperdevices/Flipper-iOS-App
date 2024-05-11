import Peripheral

import Combine

class FilteredWidgetStorage: TodayWidgetKeysStorage {
    private var widgetStorage: TodayWidgetKeysStorage
    private var mobileArchive: ArchiveProtocol

    init(widgetStorage: TodayWidgetKeysStorage, mobileArchive: ArchiveProtocol) {
        self.widgetStorage = widgetStorage
        self.mobileArchive = mobileArchive
    }

    func read() async throws -> [WidgetKey] {
        let storedKeys = try await widgetStorage.read()
        let manifest = try await mobileArchive.getManifest()
        return storedKeys.filter { manifest.items[$0.path] != nil }
    }

    func write(_ keys: [WidgetKey]) async throws {
        try await widgetStorage.write(keys)
    }
}
