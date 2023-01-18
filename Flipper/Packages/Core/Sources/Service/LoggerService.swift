import Inject
import Peripheral

import Logging
import Combine
import Foundation

public class LoggerService: ObservableObject {
    @Inject private var loggerStorage: LoggerStorage

    public var logLevel: Logger.Level {
        get { UserDefaultsStorage.shared.logLevel }
        set { UserDefaultsStorage.shared.logLevel = newValue }
    }

    public var logLevels: [Logger.Level] {
        Logger.Level.allCases
    }

    @Published public var logs: [String] = []

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        return formatter
    }()

    public init() {
        reload()
    }

    public func reload() {
        logs = loggerStorage.list().sorted {
            guard let first = formatter.date(from: $0) else { return false }
            guard let second = formatter.date(from: $1) else { return false }
            return first < second
        }
    }

    public func read(_ name: String) -> [String] {
        loggerStorage.read(name)
    }

    public func deleteAll() {
        logs.forEach(loggerStorage.delete)
        logs = loggerStorage.list().sorted()
    }

    public func delete(at indexSet: IndexSet) {
        if let index = indexSet.first {
            loggerStorage.delete(logs[index])
            logs.remove(at: index)
        }
    }
}
