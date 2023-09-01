public class Feedback {
    let loggerStorage: LoggerStorage

    public init(loggerStorage: LoggerStorage) {
        self.loggerStorage = loggerStorage
    }

    convenience public init() {
        self.init(loggerStorage: Dependencies.shared.loggerStorage)
    }

    private var logsLimit = 3

    private var attachments: [Attachment] {
        loggerStorage.list().suffix(logsLimit).map { name in
            let content = loggerStorage.read(name).joined(separator: "\n")
            return .init(filename: "\(name).txt", content: content)
        }
    }

    public func reportBug(
        subject: String,
        message: String,
        attachLogs: Bool
    ) async throws -> String {
         let event = Event(
            subject: subject,
            message: message,
            attachments: attachLogs ? attachments : [])

        let client = CentryClient()
        let response = try await client.capture(event)

        return response.id
    }
}
