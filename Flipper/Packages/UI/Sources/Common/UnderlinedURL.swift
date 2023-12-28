import SwiftUI

struct UnderlinedURL: View {
    @Environment(\.openURL) var openURL

    let image: String
    let label: String
    let url: URL

    var body: some View {
        HStack(spacing: 8) {
            Image(image)

            Button {
                openURL(url)
            } label: {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .underline()
            }
        }
    }
}
