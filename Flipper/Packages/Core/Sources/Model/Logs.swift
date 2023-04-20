import Combine
import Foundation

public class Logs: ObservableObject {
    private var loggerStorage: LoggerStorage

    public init(loggerStorage: LoggerStorage) {
        self.loggerStorage = loggerStorage
    }

    @Published public var records: [String] = []

    public func reload() {
        records = loggerStorage.list()
    }

    public func read(_ name: String) -> [String] {
        loggerStorage.read(name)
    }

    public func deleteAll() {
        records.forEach(loggerStorage.delete)
        reload()
    }

    public func delete(_ indexSet: IndexSet) {
        for index in indexSet {
            loggerStorage.delete(records[index])
        }
        reload()
    }
}
