import Core
import SwiftUI

extension ArchiveItem.FileType {
    var name: String {
        switch self {
        case .rfid: return "RFID 125"
        case .subghz: return "Sub-GHz"
        case .nfc: return "NFC"
        case .ibutton: return "iButton"
        case .infrared: return "Infrared"
        }
    }

    var icon: Image {
        switch self {
        case .ibutton: return .init("ibutton")
        case .nfc: return .init("nfc")
        case .rfid: return .init("rfid")
        case .subghz: return .init("subhz")
        case .infrared: return .init("infrared")
        }
    }

    var color: Color {
        switch self {
        case .ibutton: return .init(red: 0.88, green: 0.73, blue: 0.65)
        case .nfc: return .init(red: 0.6, green: 0.81, blue: 1.0)
        case .rfid: return .init(red: 1.0, green: 0.96, blue: 0.58)
        case .subghz: return .init(red: 0.65, green: 0.96, blue: 0.75)
        case .infrared: return .init(red: 1.0, green: 0.57, blue: 0.55)
        }
    }
}
