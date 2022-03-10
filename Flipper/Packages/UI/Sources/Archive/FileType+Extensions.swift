import Core
import SwiftUI

extension ArchiveItem.FileType {
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
        case .subghz: return .init(red: 0.65, green: 0.96, blue: 0.75)
        case .rfid: return .init(red: 1.0, green: 0.96, blue: 0.58)
        case .nfc: return .init(red: 0.6, green: 0.81, blue: 1.0)
        case .infrared: return .init(red: 1.0, green: 0.57, blue: 0.55)
        case .ibutton: return .init(red: 0.88, green: 0.73, blue: 0.65)
        }
    }
}
