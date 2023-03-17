import Peripheral

extension ArchiveItem {
    public enum Kind: Codable, Hashable, Comparable, CaseIterable {
        case subghz
        case rfid
        case nfc
        case infrared
        case ibutton
    }
}

extension ArchiveItem.Kind {
    init<T: StringProtocol>(filename: T) throws {
        guard let filetype = Peripheral.FileType(filename: filename) else {
            throw ArchiveItem.Error.invalidType(String(filename))
        }
        self = try .init(filetype)
    }

    init(_ path: Path) throws {
        guard let filename = path.lastComponent else {
            throw ArchiveItem.Error.invalidPath(path)
        }
        self = try .init(filename: filename)
    }
}

extension ArchiveItem.Kind {
    init(_ source: Peripheral.FileType) throws {
        switch source {
        case .subghz: self = .subghz
        case .rfid: self = .rfid
        case .nfc: self = .nfc
        case .infrared: self = .infrared
        case .ibutton: self = .ibutton
        default: throw ArchiveItem.Error.invalidType("\(source)")
        }
    }

    public var `extension`: String {
        switch self {
        case .rfid: return FileType.rfid.extension
        case .subghz: return FileType.subghz.extension
        case .nfc: return FileType.nfc.extension
        case .infrared: return FileType.infrared.extension
        case .ibutton: return FileType.ibutton.extension
        }
    }

    public var location: String {
        switch self {
        case .rfid: return FileType.rfid.location
        case .subghz: return FileType.subghz.location
        case .nfc: return FileType.nfc.location
        case .infrared: return FileType.infrared.location
        case .ibutton: return FileType.ibutton.location
        }
    }

    public var application: String {
        switch self {
        case .rfid: return "125 kHz RFID"
        case .subghz: return "Sub-GHz"
        case .nfc: return "NFC"
        case .infrared: return "Infrared"
        case .ibutton: return "iButton"
        }
    }
}
