import Peripheral

import Combine
import Foundation

class JSONTodayWidgetStorage: TodayWidgetKeysStorage {
    let storage: FileStorage = .init()
    let filename = "today_widget_keys.json"
    var path: Path { .init(string: filename) }

    func read() async throws -> [WidgetKey] {
        (try? await storage.read(path)) ?? []
    }

    func write(_ keys: [WidgetKey]) async throws {
        try await storage.write(keys, at: path)
        UserDefaults.group.setValue(
            "\((0...100500).randomElement() ?? 42)",
            forKey: UserDefaults.Keys.todayWidgetUpdated.rawValue)
    }
}
