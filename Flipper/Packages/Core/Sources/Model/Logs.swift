import Inject
import Foundation

public class Logs: ObservableObject {
    @Inject private var loggerStorage: LoggerStorage

    @Published public var records: [String] = []

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        return formatter
    }()

    public init() {}

    public func reload() {
        records = loggerStorage.list().sorted {
            guard let first = formatter.date(from: $0) else { return false }
            guard let second = formatter.date(from: $1) else { return false }
            return first < second
        }
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
