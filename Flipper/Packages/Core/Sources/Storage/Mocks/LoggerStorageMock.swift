import Foundation
import OrderedCollections

class LoggerStorageMock: LoggerStorage {
    private  var logs: OrderedDictionary<String, [String]> = [
        "2022-01-01": ["[info] log message 1", "[debug] log message 1"],
        "2022-01-02": ["[info] log message 2", "[debug] log message 2"],
        "2022-01-03": ["[info] log message 3", "[debug] log message 3"]
    ]

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()

    private var name: String {
        formatter.string(from: Date())
    }

    func list() -> [String] {
        .init(logs.keys)
    }

    func read(_ name: String) -> [String] {
        logs[name] ?? []
    }

    func write(_ message: String) {
        logs[name, default: []].append(message)
    }

    func delete(_ name: String) {
        logs[name] = nil
    }
}
