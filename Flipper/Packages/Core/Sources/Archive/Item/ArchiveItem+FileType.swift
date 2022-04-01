import struct Peripheral.Path
import Logging

extension ArchiveItem {
    public enum FileType: Hashable, Comparable, CaseIterable {
        case subghz
        case rfid
        case nfc
        case infrared
        case ibutton
    }
}

extension ArchiveItem.FileType {
    init<T: StringProtocol>(filename: T) throws {
        guard let `extension` = filename.split(separator: ".").last else {
            throw ArchiveItem.Error.invalidType
        }
        switch `extension` {
        case "sub": self = .subghz
        case "rfid": self = .rfid
        case "nfc": self = .nfc
        case "ir": self = .infrared
        case "ibtn": self = .ibutton
        default: throw ArchiveItem.Error.invalidType
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

    var location: String {
        switch self {
        case .rfid: return "lfrfid"
        case .subghz: return "subghz"
        case .nfc: return "nfc"
        case .infrared: return "infrared"
        case .ibutton: return "ibutton"
        }
    }
}

extension ArchiveItem.FileType {
    init(_ path: Path) throws {
        guard let filename = path.lastComponent else {
            throw ArchiveItem.Error.invalidPath
        }
        try self.init(filename: filename)
    }
}

extension ArchiveItem.FileType: CustomStringConvertible {
    public var description: String { location }
}
