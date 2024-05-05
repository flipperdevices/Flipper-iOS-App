import SwiftUI

struct SearchField: View {
    let placeholder: String
    @Binding var predicate: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .padding(.leading, 6)
                .foregroundColor(.primary.opacity(0.7))

            ZStack(alignment: .leading) {
                Text(placeholder)
                    .lineLimit(1)
                    .font(.system(size: 17))
                    .opacity(predicate.isEmpty ? 1 : 0)
                    .foregroundColor(.primary.opacity(0.7))

                FocusedTextField("", text: $predicate)
                    .lineLimit(1)
                    .submitLabel(.done)
                    .font(.system(size: 17))
                    .padding(.trailing, 6)
                    .padding(.vertical, 7)
                    .frame(height: 36)
            }

            Spacer()
        }
        .background(Color(red: 0.46, green: 0.46, blue: 0.5, opacity: 0.12))
        .cornerRadius(10)
    }
}

private struct FocusedTextField: UIViewRepresentable {
    @Binding var text: String

    init(_ titleKey: LocalizedStringKey, text: Binding<String>) {
        _text = text
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.tintColor = .label
        textField.returnKeyType = .done
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        textField.becomeFirstResponder()
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FocusedTextField

        init(_ textField: FocusedTextField) {
            self.parent = textField
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            if let currentValue = textField.text as NSString? {
                let proposedValue = currentValue
                    .replacingCharacters(in: range, with: string)
                self.parent.text = proposedValue
            }
            return true
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}
