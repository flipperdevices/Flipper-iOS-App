import SwiftUI

struct SearchToolbar: View {
    let placeholder: String
    @Binding var predicate: String
    let dismiss: DismissAction

    var body: some View {
        HStack(spacing: 14) {
            SearchField(
                placeholder: placeholder,
                predicate: $predicate)

            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.system(size: 18, weight: .regular))
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}
