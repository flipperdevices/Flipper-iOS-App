import Core
import SwiftUI

extension ArchiveItem {
    var icon: Image {
        switch fileType {
        case .ibutton: return .init("ibutton")
        case .nfc: return .init("nfc")
        case .rfid: return .init("rfid")
        case .subghz: return .init("subhz")
        case .irda: return .init("irda")
        }
    }
}

extension ArchiveItem {
    var color: Color {
        switch fileType {
        case .ibutton: return .init(red: 0.0, green: 0.48, blue: 1.0)
        case .nfc: return .init(red: 0.2, green: 0.78, blue: 0.64)
        case .rfid: return .init(red: 0.35, green: 0.34, blue: 0.84)
        case .subghz: return .init(red: 1.0, green: 0.61, blue: 0.2)
        case .irda: return .init(red: 0.69, green: 0.32, blue: 0.87)
        }
    }

    var color2: Color {
        switch fileType {
        case .ibutton: return .init(red: 0.34, green: 0.21, blue: 0.63)
        case .nfc: return .init(red: 0.15, green: 0.44, blue: 0.61)
        case .rfid: return .init(red: 0.59, green: 0.34, blue: 0.81)
        case .subghz: return .init(red: 0.84, green: 0.41, blue: 0.17)
        case .irda: return .init(red: 0.86, green: 0.47, blue: 47)
        }
    }
}
