import Analytics
import Sentry
import UIKit

public class Feedback {
    let loggerStorage: LoggerStorage

    public init(loggerStorage: LoggerStorage) {
        self.loggerStorage = loggerStorage
    }

    convenience public init() {
        self.init(loggerStorage: Dependencies.shared.loggerStorage)
    }

    enum Error: Swift.Error {
        case dsnNotFound
        case clientError
    }

    private var sentryDSN: String? {
        #if DEBUG
        ProcessInfo().environment["SENTRY_DSN"]
        #else
        Bundle.main.object(forInfoDictionaryKey: "SENTRY_DSN") as? String
        #endif
    }

    private var environment: String {
        #if DEBUG
        return "DEBUG"
        #else
        return Bundle.isAppStoreBuild ? "App Store" : "TestFlight"
        #endif
    }

    private var options: Options {
        get throws {
            guard let sentryDSN, !sentryDSN.isEmpty else {
                logger.error("report bug: SENTRY_DSN not found")
                throw Error.dsnNotFound
            }
            let options = Options()
            options.dsn = sentryDSN
            options.attachStacktrace = false
            options.attachViewHierarchy = false
            return options
        }
    }

    private var logsLimit = 3

    private var attachments: [Attachment] {
        loggerStorage.list().suffix(logsLimit).map { name in
            let content = loggerStorage.read(name).joined(separator: "\n")
            return .init(data: .init(content.utf8), filename: "\(name).txt")
        }
    }

    public func reportBug(
        subject: String,
        message: String,
        attachLogs: Bool
    ) async throws -> String {
        guard let client = try SentryClient(options: options) else {
            throw Error.clientError
        }

        let event = Event(level: .warning)
        event.user = .init(userId: DeviceID.uuidString)
        event.message = .init(formatted: subject)
        event.environment = environment

        // TODO: Add Flipper target & version

        let systemName = await UIDevice.current.systemName
        let systemVersion = await UIDevice.current.systemVersion

        // NOTE: Use of `event.context` ends up with some sensitive info
        // automaticaly added to event scope (e.g. device id, timezone, battery)

        event.tags = [
            "os": "\(systemName) \(systemVersion)"
        ]

        // Add attachments

        let scope = Scope()

        if attachLogs {
            attachments.forEach(scope.addAttachment)
        }

        let id = client.capture(event: event, scope: scope)

        // Add feedback

        let feedback = UserFeedback(eventId: id)
        feedback.comments = message
        client.capture(userFeedback: feedback)

        // Flush

        client.flush(timeout: .infinity)

        return id.sentryIdString
    }
}
