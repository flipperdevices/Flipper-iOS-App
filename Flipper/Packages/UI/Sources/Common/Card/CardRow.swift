import SwiftUI

struct CardRow: View {
    let name: String
    let value: String

    var body: some View {
        HStack {
            Text("\(name)")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.leading)
                .foregroundColor(.black30)
            Spacer()
            if !value.isEmpty {
                Text("\(value)")
                    .font(.system(size: 14, weight: .regular))
                    .multilineTextAlignment(.trailing)
            } else {
                AnimatedPlaceholder()
                    .frame(width: 50, height: 17)
            }
        }
    }
}
