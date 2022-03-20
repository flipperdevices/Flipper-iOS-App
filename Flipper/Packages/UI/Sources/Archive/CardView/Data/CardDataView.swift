import Core
import SwiftUI

struct CardDataView: View {
    @Binding var item: ArchiveItem
    let isEditing: Bool
    @Binding var focusedField: String

    var body: some View {
        switch item.fileType {
        case .rfid:
            RFIDCardView(
                item: _item,
                isEditing: isEditing,
                focusedField: $focusedField
            )
        case .subghz:
            SUBGHZCardView(
                item: _item,
                isEditing: isEditing,
                focusedField: $focusedField
            )
        case .nfc:
            NFCCardView(
                item: _item,
                isEditing: isEditing,
                focusedField: $focusedField
            )
        case .ibutton:
            IButtonCardView(
                item: _item,
                isEditing: isEditing,
                focusedField: $focusedField
            )
        case .infrared:
            InfraredCardView(
                item: _item,
                isEditing: isEditing,
                focusedField: $focusedField
            )
        }
    }
}
