import Core
import SwiftUI

struct KeyView: View {
    let key: MFKey64

    init(_ key: MFKey64) {
        self.key = key
    }

    var body: some View {
        HStack(spacing: 6) {
            Image("FoundKey")
            Text(key.hexValue.uppercased())
                .foregroundColor(.primary.opacity(0.8))
                .font(.system(
                    size: 12,
                    weight: .medium,
                    design: .monospaced))
        }
        .padding(.leading, 10)
        .padding(.trailing, 12)
        .padding(.vertical, 12)
        .background(Color.groupedBackground)
        .cornerRadius(30)
    }
}
