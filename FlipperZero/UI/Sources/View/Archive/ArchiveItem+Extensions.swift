import Core
import SwiftUI

extension ArchiveItem {
    var icon: Image {
        switch kind {
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
        switch kind {
        case .ibutton: return .init(red: 0.0, green: 0.48, blue: 1.0)
        case .nfc: return .init(red: 0.2, green: 0.78, blue: 0.64)
        case .rfid: return .init(red: 0.35, green: 0.34, blue: 0.84)
        case .subghz: return .init(red: 1.0, green: 0.61, blue: 0.2)
        case .irda: return .init(red: 0.69, green: 0.32, blue: 0.87)
        }
    }
}
