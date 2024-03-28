import SwiftUI

struct InfoButton: View {
    let image: String
    let title: String
    let action: () -> Void

    init(
        image: String,
        title: String,
        action: @escaping () -> Void
    ) {
        self.image = image
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(image)
                    .renderingMode(.template)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(minWidth: 44, minHeight: 44)
            .padding(.trailing, 44)
        }
    }
}
