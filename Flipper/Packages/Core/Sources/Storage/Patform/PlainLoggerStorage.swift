import Peripheral
import Foundation
import OrderedCollections

actor PlainLoggerStorage: LoggerStorage {
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
        Task { await cleanup(limit: 10) }
    }

    private func cleanup(limit: Int) async {
        try? await storage.append("", at: currentLogPath)
        for item in await list().dropLast(limit) {
            await delete(item)
        }
    }

    func list() async -> [String] {
        let files = (try? await storage.list(at: directory)) ?? []
        return files.sorted {
            guard let first = formatter.date(from: $0) else { return false }
            guard let second = formatter.date(from: $1) else { return false }
            return first < second
        }
    }

    func read(_ name: String) async -> [String] {
        do {
            let log: String = try await storage.read(directory.appending(name))
            return log.split(separator: "\n").map { String($0) }
        } catch {
            print("read log: \(error)")
            return ["read log: \(error)"]
        }
    }

    func write(_ message: String) async {
        try? await storage.append("\(message)\n", at: currentLogPath)
    }

    func delete(_ name: String) async {
        try? await storage.delete(directory.appending(name))
    }
}
