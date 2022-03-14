import SwiftUI

struct PropertyView: View {
    let name: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .foregroundColor(.black30)
            Text(value)
                .lineLimit(3)
        }
        .font(.system(size: 14, weight: .medium))
    }
}
