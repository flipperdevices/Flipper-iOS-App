import AppIntents

struct KeyEntity: AppEntity, Identifiable {
    // Placeholder whenever it needs to present your entity’s type onscreen.
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Key"
    static let defaultQuery = KeyQuery()

    static let invalid = KeyEntity(
        id: "-",
        name: "Not Configured",
        kind: .subghz
    )

    let id: String
    let name: String
    let kind: Kind

    public enum Kind {
        case subghz
        case rfid
        case nfc
        case infrared
        case ibutton
    }

    var displayRepresentation: DisplayRepresentation {
        .init(
            title: "\(name)",
            subtitle: "\(kind.subtitle)",
            image: .init(named: kind.image, isTemplate: true)
        )
    }
}

extension KeyEntity {
    init?(path: String) {
        guard
            let filename = path.split(separator: "/").last,
            let ext = filename.split(separator: ".").last,
            let kind = Kind(ext)
        else {
            return nil
        }
        self.id = path
        self.name = .init(filename.dropLast(ext.count + 1))
        self.kind = kind
    }
}

extension KeyEntity.Kind {
    init?(_ ext: some StringProtocol) {
        switch ext {
        case "sub": self = .subghz
        case "rfid": self = .rfid
        case "nfc": self = .nfc
        case "ir": self = .infrared
        case "ibtn": self = .ibutton
        default: return nil
        }
    }

    var subtitle: String {
        switch self {
        case .subghz: "Sub-GHz"
        case .rfid: "RFID 125"
        case .nfc: "NFC"
        case .infrared: "Infrared"
        case .ibutton: "iButton"
        }
    }

    var image: String {
        switch self {
        case .subghz: "subghz"
        case .rfid: "rfid"
        case .nfc: "nfc"
        case .infrared: "infrared"
        case .ibutton: "ibutton"
        }
    }
}
