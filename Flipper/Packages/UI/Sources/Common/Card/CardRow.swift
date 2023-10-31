import SwiftUI

struct CardRow: View {
    let name: String
    let formattedValue: Any?
    let plainStringValue: String?

    init(name: String, value: String?) {
        self.name = name
        self.formattedValue = nil
        self.plainStringValue = value
    }

    @available(iOS 15.0, *)
    init(name: String, value: AttributedString?) {
        self.name = name
        self.formattedValue = value
        if let value = value {
            self.plainStringValue = value.description
        } else {
            self.plainStringValue = nil
        }
    }

    var body: some View {
        HStack {
            Text("\(name)")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.leading)
                .foregroundColor(.black30)
            Spacer()
            if formattedValue != nil || plainStringValue != nil {
                if #available(iOS 15, *), let value = formattedValue as? AttributedString {
                    Text(value)
                        .font(.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.trailing)
                } else if let value = plainStringValue {
                    Text(value)
                        .font(.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.trailing)
                }
            } else {
                AnimatedPlaceholder()
                    .frame(width: 50, height: 17)
            }
        }
    }
}
