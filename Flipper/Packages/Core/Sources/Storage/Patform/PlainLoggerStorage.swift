import Peripheral
import Foundation
import OrderedCollections

class PlainLoggerStorage: LoggerStorage {
    let storage: FileStorage = .init()
    private let directory = Path("logs")

    private  var logs: OrderedDictionary<String, [String]> = [:]

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        return formatter
    }()

    private var current: String

    init() {
        current = formatter.string(from: Date())
    }

    func list() -> [String] {
        (try? storage.list(at: directory).map { $0.string }) ?? []
    }

    func read(_ name: String) -> [String] {
        guard let log = try? storage.read(directory.appending(name)) else {
            return []
        }
        return log.split(separator: "\n").map { String($0) }
    }

    func write(_ message: String) {
        try? storage.append("\(message)\n", at: directory.appending(current))
    }

    func delete(_ name: String) {
        try? storage.delete(directory.appending(name))
    }
}
