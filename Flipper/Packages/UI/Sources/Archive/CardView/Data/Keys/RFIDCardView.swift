import Core
import SwiftUI

struct RFIDCardView: View {
    @Binding var item: ArchiveItem
    let isEditing: Bool
    @Binding var focusedField: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PropertyView(name: "Key Type:", value: item.keyName)
            PropertyView(name: "Data:", value: item.data)
        }
    }
}

fileprivate extension ArchiveItem {
    var data: String { self["Data"] ?? "" }
    var keyType: String { self["Key type"] ?? "" }

    var keyName: String {
        switch keyType {
        case "EM4100": return "EM-Marin"
        case "H10301": return "HID"
        case "I40134": return "Indala"
        default: return ""
        }
    }
}
