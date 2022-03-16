import SwiftUI

struct SheetEditHeader: View {
    let title: String
    let onSave: @MainActor () -> Void
    let onCancel: @MainActor () -> Void

    init(
        _ title: String,
        onSave: @escaping @MainActor () -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        self.title = title
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
            Text(title)
                .font(.system(size: 18, weight: .bold))
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
