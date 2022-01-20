import Logging
import Inject

// swiftlint:disable function_parameter_count

struct FileLogHandler: LogHandler {
    @Inject var storage: LoggerStorage

    static func factory(_ label: String) -> FileLogHandler {
        return .init(metadata: .init(), logLevel: .info)
    }

    var metadata: Logger.Metadata
    var logLevel: Logger.Level

    subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get { self.metadata[metadataKey] }
        set { self.metadata[metadataKey] = newValue }
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
        print(message)
        #endif
        storage.write("\(message)")
    }
}
