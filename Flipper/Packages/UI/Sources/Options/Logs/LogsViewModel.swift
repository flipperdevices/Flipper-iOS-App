import Core
import Inject
import Combine
import Foundation
import Logging
import SwiftUI

@MainActor
class LogsViewModel: ObservableObject {
    private let logger = Logger(label: "logs-vm")
    @Inject private var loggerStorage: LoggerStorage

    @Published var logs: [String] = []
    @AppStorage(.logLevelKey) var logLevel: Logger.Level = .debug

    var logLevels: [Logger.Level] {
        Logger.Level.allCases
    }

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        return formatter
    }()

    init() {
        logs = loggerStorage.list().sorted {
            guard let first = formatter.date(from: $0) else { return false }
            guard let second = formatter.date(from: $1) else { return false }
            return first < second
        }
    }

    func changeLogLevel(to level: Logger.Level) {
        logLevel = level
        logger.info("log level changed to \(level)")
    }

    func deleteAll() {
        logs.forEach(loggerStorage.delete)
        logs = loggerStorage.list().sorted()
    }

    func delete(at indexSet: IndexSet) {
        if let index = indexSet.first {
            loggerStorage.delete(logs[index])
            logs.remove(at: index)
        }
    }
}
