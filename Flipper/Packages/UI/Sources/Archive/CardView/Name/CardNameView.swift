import Core
import SwiftUI

extension CardView {
    struct CardNameView: View {
        @Binding var item: ArchiveItem
        let kind: Kind
        let isEditing: Bool
        @Binding var focusedField: String

        var body: some View {
            if isEditing {
                CardNameEditView(item: $item, focusedField: $focusedField)
            } else {
                CardNameInfoView(item: $item, kind: kind)
            }
        }
    }
}
