import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    enum Kind {
        case sendable
        case emulatable
    }

    @Parameter(title: "Archive Key", default: .none)
    var entity: KeyEntity

    init() {
        self.entity = .invalid
    }

    init(entity: KeyEntity) {
        self.entity = entity
    }

    var kind: Kind {
        switch entity.kind {
        case .subghz: return .sendable
        case .rfid: return .emulatable
        case .nfc: return .emulatable
        case .infrared: return .sendable
        case .ibutton: return .emulatable
        }
    }
}
