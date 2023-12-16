import Combine
import Foundation

public class Logs: ObservableObject {
    private var loggerStorage: LoggerStorage

    public init(loggerStorage: LoggerStorage) {
        self.loggerStorage = loggerStorage
    }

    @Published public var records: [String] = []

    public func reload() {
        Task { @MainActor in
            records = await loggerStorage.list()
        }
    }

    public func read(_ name: String) async -> [String] {
        await loggerStorage.read(name)
    }

    public func deleteAll() async {
        for record in records {
            await loggerStorage.delete(record)
        }
        reload()
    }

    public func delete(_ indexSet: IndexSet) async {
        for index in indexSet {
            await loggerStorage.delete(records[index])
        }
        reload()
    }
}
