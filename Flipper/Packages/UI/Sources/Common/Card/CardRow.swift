import SwiftUI
import AttributedText
import UIKit

struct CardRow: View {
    let name: String
    let formattedValue: Any?
    let plainStringValue: String

    init(name: String, value: String) {
        self.name = name
        self.formattedValue = nil
        self.plainStringValue = value
    }

    @available(iOS 15.0, *)
    init(name: String, value: AttributedString) {
        self.name = name
        self.formattedValue = value
        self.plainStringValue = value.description
    }

    var body: some View {
        HStack {
            Text("\(name)")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.leading)
                .foregroundColor(.black30)
            Spacer()
            if !plainStringValue.description.isEmpty {
                if #available(iOS 15, *), let value = formattedValue as? AttributedString {
                    Text(value)
                        .font(.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(plainStringValue)
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
