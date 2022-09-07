import SwiftUI

struct SheetHeader: View {
    let title: String
    let description: String?
    let onCancel: () -> Void

    init(
        title: String,
        description: String? = nil,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.onCancel = onCancel
    }

    var body: some View {
        HStack {
            Image(systemName: "xmark")
                .font(.system(size: 20, weight: .medium))
                .opacity(0)
            Spacer()

            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                if let description = description {
                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                }
            }

            Spacer()
            Button(action: onCancel) {
                Image(systemName: "xmark")
            }
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(.primary)
        }
        .padding(.horizontal, 19)
        .padding(.top, 17)
        .padding(.bottom, 6)
    }
}
