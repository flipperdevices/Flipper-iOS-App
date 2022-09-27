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
                .onReceive(Just(item.name.value)) { newValue in
                    let filtered = newValue.filtered().prefix(nameLimit)
                    guard filtered != newValue else { return }
                    item.name.value = String(filtered)
                }

                UTextField(
                    title: "Note:",
                    placeholder: "",
                    text: $item.note,
                    focusedField: $focusedField
                )
                .font(.system(size: 14, weight: .medium))
                .onReceive(Just(item.name.value)) { newValue in
                    let filtered = newValue.prefix(noteLimit)
                    guard filtered != newValue else { return }
                    item.name.value = String(filtered)
                }
            }
        }
    }
}

private extension StringProtocol {
    var allowedCharacters: String {
        #"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"# +
        #"!#\$%&'()-@^_`{}~ "#
    }

    func filtered() -> String {
        .init(filter { allowedCharacters.contains($0) })
    }
}
