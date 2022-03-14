import Core
import SwiftUI

extension CardView {
    struct CardNameEditView: View {
        @Binding var item: ArchiveItem
        @Binding var focusedField: String

        var body: some View {
            VStack(alignment: .leading, spacing: 18) {
                UTextField(
                    title: "Name:",
                    placeholder: "Key_name",
                    text: $item.name.value,
                    focusedField: $focusedField
                )
                .font(.system(size: 14, weight: .medium))

                UTextField(
                    title: "Note:",
                    placeholder: "",
                    text: $item.note,
                    focusedField: $focusedField
                )
                .font(.system(size: 14, weight: .medium))
            }
        }
    }
}
