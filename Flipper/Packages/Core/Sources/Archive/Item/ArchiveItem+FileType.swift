import Logging

extension ArchiveItem {
    public enum FileType: Hashable, Comparable, CaseIterable, Codable {
        case ibutton
        case nfc
        case rfid
        case subghz
        case irda
    }
}

extension ArchiveItem.FileType {
    init<T: StringProtocol>(filename: T) throws {
        guard let `extension` = filename.split(separator: ".").last else {
            throw ArchiveItem.Error.invalidType
        }
        switch `extension` {
        case "ibtn": self = .ibutton
        case "nfc": self = .nfc
        case "sub": self = .subghz
        case "rfid": self = .rfid
        case "ir": self = .irda
        default: throw ArchiveItem.Error.invalidType
        }
    }

    public var `extension`: String {
        switch self {
        case .ibutton: return "ibtn"
        case .nfc: return "nfc"
        case .subghz: return "sub"
        case .rfid: return "rfid"
        case .irda: return "ir"
        }
    }

    var location: String {
        switch self {
        case .ibutton: return "ibutton"
        case .nfc: return "nfc"
        case .subghz: return "subghz"
        case .rfid: return "lfrfid"
        case .irda: return "irda"
        }
    }
}

extension ArchiveItem.FileType: CustomStringConvertible {
    public var description: String { location }
}
