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
        get async {
            var result: [Attachment] = []
            for file in await loggerStorage.list().suffix(logsLimit) {
                let content = await loggerStorage
                    .read(file)
                    .joined(separator: "\n")
                result.append(.init(filename: "\(file).txt", content: content))
            }
            return result
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
            attachments: attachLogs ? await attachments : [])

        let client = CentryClient()
        let response = try await client.capture(event)

        return response.id
    }
}
