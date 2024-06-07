import SwiftUI

struct TabViewItem: View {
    let image: AnyView
    let name: String
    let isSelected: Bool
    let onItemSelected: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                image

                Text(name)
                    .lineLimit(1)
                    .font(.system(size: 10, weight: .bold))
            }
            .padding(.horizontal, 7)
            .frame(minWidth: 69, minHeight: 46)
            .contentShape(Rectangle())
            .onTapGesture {
                onItemSelected()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
