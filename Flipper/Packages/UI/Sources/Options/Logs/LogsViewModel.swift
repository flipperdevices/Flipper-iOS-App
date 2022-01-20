import Core
import Inject
import Combine
import Foundation

@MainActor
class LogsViewModel: ObservableObject {
    @Inject private var loggerStorage: LoggerStorage

    @Published var logs: [String] = []

    init() {
        logs = loggerStorage.list()
    }

    func delete(at indexSet: IndexSet) {
        if let index = indexSet.first {
            loggerStorage.delete(logs[index])
            logs.remove(at: index)
        }
    }
}
