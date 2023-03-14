import Analytics
import Sentry
import UIKit

public class Support {
    public init() {
    }

    enum Error: Swift.Error {
        case dsnNotFound
        case clientError
    }

    private static var sentryDSN: String? {
        #if DEBUG
        ProcessInfo().environment["SENTRY_DSN"]
        #else
        Bundle.main.object(forInfoDictionaryKey: "SENTRY_DSN") as? String
        #endif
    }

    private static var isAppStoreBuild: Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }
        let receiptData = try? Data(contentsOf: receiptURL)
        return receiptData != nil
    }

    private static var environment: String {
        #if DEBUG
        return "DEBUG"
        #else
        return isAppStoreBuild ? "App Store" : "TestFlight"
        #endif
    }

    private static var options: Options {
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

    public static func reportBug(
        subject: String,
        message: String,
        attachLogs: Bool
    ) async throws -> String {
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

        guard let client = try SentryClient(options: options) else {
            throw Error.clientError
        }
        let id = client.capture(event: event)
        let feedback = UserFeedback(eventId: id)
        feedback.comments = message
        client.capture(userFeedback: feedback)
        client.flush(timeout: .infinity)

        return id.sentryIdString
    }
}

