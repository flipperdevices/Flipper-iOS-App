import Core
import SwiftUI

extension ArchiveItem.Kind {
    var name: String {
        switch self {
        case .subghz: return "Sub-GHz"
        case .rfid: return "RFID 125"
        case .nfc: return "NFC"
        case .infrared: return "Infrared"
        case .ibutton: return "iButton"
        }
    }

    var icon: Image {
        switch self {
        case .subghz: return .init("subhz")
        case .rfid: return .init("rfid")
        case .nfc: return .init("nfc")
        case .infrared: return .init("infrared")
        case .ibutton: return .init("ibutton")
        }
    }

    var color: Color {
        switch self {
        case .subghz: return .subGHz
        case .rfid: return .rfid125
        case .nfc: return .nfc
        case .infrared: return .infrared
        case .ibutton: return .iButton
        }
    }
}
