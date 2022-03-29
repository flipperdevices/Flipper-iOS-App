public enum FileType: Hashable, Comparable, CaseIterable, Codable {
    case subghz
    case rfid
    case nfc
    case infrared
    case ibutton
}

extension FileType {
    init?<T: StringProtocol>(filename: T) {
        guard let `extension` = filename.split(separator: ".").last else {
            return nil
        }
        switch `extension` {
        case "sub": self = .subghz
        case "rfid": self = .rfid
        case "nfc": self = .nfc
        case "ir": self = .infrared
        case "ibtn": self = .ibutton
        default: return nil
        }
    }

    public var `extension`: String {
        switch self {
        case .rfid: return "rfid"
        case .subghz: return "sub"
        case .nfc: return "nfc"
        case .infrared: return "ir"
        case .ibutton: return "ibtn"
        }
    }

    public var location: String {
        switch self {
        case .rfid: return "lfrfid"
        case .subghz: return "subghz"
        case .nfc: return "nfc"
        case .infrared: return "infrared"
        case .ibutton: return "ibutton"
        }
    }
}

extension FileType: CustomStringConvertible {
    public var description: String { location }
}
