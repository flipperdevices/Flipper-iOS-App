import SwiftUI

struct UTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @Binding var focusedField: String

    var isFocused: Bool {
        focusedField == title
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black30)
            ZStack(alignment: .leading) {
                Text(placeholder)
                    .foregroundColor(.black8)
                    .opacity(text.isEmpty ? 1 : 0)
                TextField("", text: $text) { focused in
                    focusedField = focused ? title : ""
                }
                .submitLabelDoneIfAvailable()
                .disableAutocorrection(true)
            }
            .padding(.top, 4)
            Divider()
                .frame(height: 1)
                .background(isFocused ? Color.accentColor : .black30)
                .padding(.top, 2)
        }
    }
}
