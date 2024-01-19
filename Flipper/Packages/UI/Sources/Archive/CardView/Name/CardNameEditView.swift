import Core
import SwiftUI
import Combine

extension CardView {
    struct CardNameEditView: View {
        @Binding var item: ArchiveItem
        @Binding var focusedField: String

        let nameLimit = 22
        let noteLimit = 120

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
            .onChange(of: item.name.value) { _ in
                updateName()
            }
            .onChange(of: item.note) { _ in
                updateNote()
            }
            .onAppear {
                updateName()
                updateNote()
            }
        }

        func updateName() {
            let filtered = ArchiveItem
                .filterInvalidCharacters(item.name.value)
                .prefix(nameLimit)

            guard filtered != item.name.value else { return }
            item.name.value = String(filtered)
        }

        func updateNote() {
            let filtered = ArchiveItem
                .filterInvalidCharacters(item.note)
                .prefix(noteLimit)

            guard filtered != item.note else { return }
            item.note = String(filtered)
        }
    }
}
