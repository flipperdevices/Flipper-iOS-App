import SwiftUI

struct ActionButton: View {
    let image: String
    let title: String
    let action: @MainActor () -> Void

    init(
        image: String,
        title: String,
        action: @escaping @MainActor () -> Void
    ) {
        self.image = image
        self.title = title
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(image)
                    .renderingMode(.template)

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.vertical, 12)

                Spacer()
            }
            .frame(height: 42)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .background(Color.groupedBackground)
        }
    }
}
