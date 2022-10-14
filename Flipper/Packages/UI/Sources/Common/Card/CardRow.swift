import SwiftUI
import AttributedText

struct CardRow: View {
    let name: String
    let value: NSAttributedString

    init(name: String, value: String) {
        self.init(name: name, value: NSAttributedString(string: value))
    }

    init(name: String, value: NSAttributedString) {
        self.name = name
        self.value = value
    }

    var body: some View {
        HStack {
            Text("\(name)")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.leading)
                .foregroundColor(.black30)
            Spacer()
            if !value.description.isEmpty {
                AttributedText(value)
                    .font(.system(size: 14, weight: .regular))
                    .multilineTextAlignment(.trailing)
            } else {
                AnimatedPlaceholder()
                    .frame(width: 50, height: 17)
            }
        }
    }
}
