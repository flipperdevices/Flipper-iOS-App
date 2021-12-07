import Core
import SwiftUI

struct RFIDCardView: View {
    @Binding var item: ArchiveItem
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("HEX:")
                Text(item.data)
            }
            .font(.system(size: 18, weight: .bold))

            HStack {
                Text(item.keyName)
                Spacer()
                Text(item.keyType)
            }
            .font(.system(size: 16, weight: .medium))
        }
        .padding(.top, 16)
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
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
