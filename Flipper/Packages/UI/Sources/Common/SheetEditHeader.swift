import SwiftUI

struct SheetEditHeader: View {
    let title: String
    let onSave: () -> Void
    let onCancel: () -> Void

    init(
        _ title: String,
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        HStack {
            Button("Cancel", action: onCancel)
                .frame(width: 66)
            Spacer()
            Text(title)
                .font(.system(size: 18, weight: .bold))
            Spacer()
            Button("Save", action: onSave)
                .frame(width: 66)
        }
        .padding(.horizontal, 11)
        .padding(.top, 17)
        .padding(.bottom, 6)
    }
}
