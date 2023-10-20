import Core
import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct PlayAlert: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "PlayAlertIntent"

    static var title: LocalizedStringResource {
        "Play Alert"
    }

    static var description: IntentDescription {
        "Play Audiovisual Alert on Flipper"
    }

    func perform() async throws -> some IntentResult {
        // next step
        await Dependencies.shared.device.playAlert()
        return .result()
    }
}
