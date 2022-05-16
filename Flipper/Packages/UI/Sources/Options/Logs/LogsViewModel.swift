import Core
import Inject
import Combine
import Foundation

@MainActor
class LogsViewModel: ObservableObject {
    @Inject private var loggerStorage: LoggerStorage

    @Published var logs: [String] = []

    init() {
        logs = loggerStorage.list().sorted()
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
