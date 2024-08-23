public enum FileType: Hashable, Comparable, CaseIterable {
    case subghz
    case rfid
    case nfc
    case shadow
    case infrared
    case infraredUI
    case ibutton
}

extension FileType {
    public init?<T: StringProtocol>(filename: T) {
        guard let `extension` = filename.split(separator: ".").last else {
            return nil
        }
        switch `extension` {
        case "sub": self = .subghz
        case "rfid": self = .rfid
        case "nfc": self = .nfc
        case "shd": self = .shadow
        case "ir": self = .infrared
        case "irui": self = .infraredUI
        case "ibtn": self = .ibutton
        default: return nil
        }
    }

    public var `extension`: String {
        switch self {
        case .rfid: return "rfid"
        case .subghz: return "sub"
        case .nfc: return "nfc"
        case .shadow: return "shd"
        case .infrared: return "ir"
        case .infraredUI: return "irui"
        case .ibutton: return "ibtn"
        }
    }

    public var location: String {
        switch self {
        case .rfid: return "lfrfid"
        case .subghz: return "subghz"
        case .nfc: return "nfc"
        case .shadow: return "nfc"
        case .infrared: return "infrared"
        case .infraredUI: return "infrared"
        case .ibutton: return "ibutton"
        }
    }

    public var matchLayout: FileType? {
        switch self {
        case .infrared: return .infraredUI
        default: return nil
        }
    }

    public var matchOrigin: FileType? {
        switch self {
        case .infraredUI: return .infrared
        case .shadow: return .nfc
        default: return nil
        }
    }

    public static var supportedLayouts: [FileType] {
        return [.infraredUI]
    }
}

extension FileType: CustomStringConvertible {
    public var description: String { location }
}
