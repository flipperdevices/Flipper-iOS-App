import Foundation
import OrderedCollections

class JSONLoggerStorage: LoggerStorage {
    private  var logs: OrderedDictionary<String, [String]> = [:]

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
