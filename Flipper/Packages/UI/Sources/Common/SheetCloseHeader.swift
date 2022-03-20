import SwiftUI

struct SheetHeader: View {
    let title: String
    let onCancel: () -> Void

    init(_ title: String, onCancel: @escaping () -> Void) {
        self.title = title
        self.onCancel = onCancel
    }

    var body: some View {
        HStack {
            Image(systemName: "xmark")
                .font(.system(size: 20, weight: .medium))
                .opacity(0)
            Spacer()
            Text(title)
                .font(.system(size: 18, weight: .bold))
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
