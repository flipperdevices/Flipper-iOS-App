import SwiftUI

struct CardTextField: View {
    let title: String
    @Binding var text: String
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    var body: some View {
        TextField("", text: $text) { focused in
            focusedField = focused ? title : ""
        }
        .disableAutocorrection(true)
        .disabled(!isEditMode)
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(Color.white.opacity(isEditMode ? 0.3 : 0))
        .border(Color.white.opacity(focusedField == title ? 1 : 0), width: 2)
        .cornerRadius(4)
    }
}
