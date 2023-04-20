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

    private var currentLogName: String

    private var currentLogPath: Path {
        directory.appending(currentLogName)
    }

    init(recordsLimit: Int = 10) {
        currentLogName = formatter.string(from: Date())
        cleanup(limit: 10)
    }

    private func cleanup(limit: Int) {
        try? storage.append("", at: currentLogPath)
        list().dropLast(limit).forEach(delete)
    }

    func list() -> [String] {
        let files = (try? storage.list(at: directory)) ?? []
        return files.sorted {
            guard let first = formatter.date(from: $0) else { return false }
            guard let second = formatter.date(from: $1) else { return false }
            return first < second
        }
    }

    func read(_ name: String) -> [String] {
        guard let log = try? storage.read(directory.appending(name)) else {
            return []
        }
        return log.split(separator: "\n").map { String($0) }
    }

    func write(_ message: String) {
        try? storage.append("\(message)\n", at: currentLogPath)
    }

    func delete(_ name: String) {
        try? storage.delete(directory.appending(name))
    }
}
