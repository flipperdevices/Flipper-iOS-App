import SwiftUI

struct SheetEditHeader: View {
    let title: String
    let description: String?
    let onSave: @MainActor () -> Void
    let onCancel: @MainActor () -> Void

    init(
        title: String,
        description: String? = nil,
        onSave: @escaping @MainActor () -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.description = description
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        HStack {
            Button("Cancel") {
                onCancel()
            }
            .frame(width: 66)
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
            Button("Save") {
                onSave()
            }
            .frame(width: 66)
        }
        .padding(.horizontal, 11)
        .padding(.top, 17)
        .padding(.bottom, 6)
    }
}
