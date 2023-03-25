import SwiftUI

struct CardRow: View {
    let name: String
    let value: AttributedString?

    init(name: String, value: String?) {
        self.name = name
        if let value = value {
            self.value = .init(value)
        } else {
            self.value = nil
        }
    }

    init(name: String, value: AttributedString?) {
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
            if let value = value {
                Text(value)
                    .font(.system(size: 14, weight: .regular))
                    .multilineTextAlignment(.trailing)
            } else {
                AnimatedPlaceholder()
                    .frame(width: 50, height: 17)
            }
        }
    }
}
