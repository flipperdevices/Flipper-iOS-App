import Core
import SwiftUI

struct CardDataView: View {
    @Binding var item: ArchiveItem
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    let flipped: Bool

    var body: some View {
        switch item.fileType {
        case .rfid:
            RFIDCardView(
                item: _item,
                isEditMode: $isEditMode,
                focusedField: $focusedField,
                flipped: flipped
            )
        case .subghz:
            SUBGHZCardView(
                item: _item,
                isEditMode: $isEditMode,
                focusedField: $focusedField,
                flipped: flipped
            )
        case .nfc:
            NFCCardView(
                item: _item,
                isEditMode: $isEditMode,
                focusedField: $focusedField,
                flipped: flipped
            )
        case .ibutton:
            IButtonCardView(
                item: _item,
                isEditMode: $isEditMode,
                focusedField: $focusedField,
                flipped: flipped
            )
        case .infrared:
            InfraredCardView(
                item: _item,
                isEditMode: $isEditMode,
                focusedField: $focusedField,
                flipped: flipped
            )
        }
    }
}
