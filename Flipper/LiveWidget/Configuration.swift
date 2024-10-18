import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    enum Kind {
        case sendable
        case emulatable
    }

    @Parameter(title: "Archive Key")
    private var _entity: KeyEntity?

    var entity: KeyEntity {
        _entity ?? KeyEntity.invalid
    }

    init() {
        self._entity = .invalid
    }

    init(entity: KeyEntity) {
        self._entity = entity
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
