import Logging
import Foundation

// swiftlint:disable function_parameter_count

struct FileLogHandler: LogHandler {
    private let storage: LoggerStorage

    init(storage: LoggerStorage) {
        self.storage = storage
    }

    var metadata: Logger.Metadata = .init()
    var logLevel: Logger.Level = UserDefaultsStorage.shared.logLevel

    subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get { self.metadata[metadataKey] }
        set { self.metadata[metadataKey] = newValue }
    }

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()

    var time: String {
        formatter.string(from: .init())
    }

    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        #if DEBUG
        print("[\(time)][\(level)]: \(message)")
        #endif
        storage.write("[\(time)][\(level)]: \(message)")
    }
}
