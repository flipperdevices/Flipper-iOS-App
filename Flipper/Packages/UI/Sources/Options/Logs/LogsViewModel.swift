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

    init() {
        logs = loggerStorage.list().sorted()
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
