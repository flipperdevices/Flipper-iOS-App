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
    init?<T: StringProtocol>(fileName: T) {
        guard let `extension` = fileName.split(separator: ".").last else {
            return nil
        }
        switch `extension` {
        case "ibtn": self = .ibutton
        case "nfc": self = .nfc
        case "sub": self = .subghz
        case "rfid": self = .rfid
        case "ir": self = .irda
        default: return nil
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
        case .subghz: return "subghz/saved"
        case .rfid: return "lfrfid"
        case .irda: return "irda"
        }
    }
}

extension ArchiveItem.FileType: CustomStringConvertible {
    public var description: String { location }
}
