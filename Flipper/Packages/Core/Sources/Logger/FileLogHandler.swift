import Logging
import Inject
import Foundation

// swiftlint:disable function_parameter_count

struct FileLogHandler: LogHandler {
    @Inject var storage: LoggerStorage

    static func factory(_ label: String) -> FileLogHandler {
        return .init(metadata: .init(), logLevel: .debug)
    }

    var metadata: Logger.Metadata
    var logLevel: Logger.Level

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
