import SwiftUI

struct TabViewItem: View {
    let image: AnyView
    let name: String
    let isSelected: Bool
    let hasNotification: Bool
    let onItemSelected: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    image

                    Circle()
                        .frame(width: 12, height: 12)
                        .offset(x: -3, y: 3)
                        .foregroundColor(.a1)
                        .opacity(hasNotification ? 1 : 0)
                }

                Text(name)
                    .font(.system(size: 10, weight: .bold))
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .frame(minWidth: 69)
            .background(
                isSelected
                    ? RoundedRectangle(cornerRadius: 8).fill(Color.black4)
                    : nil
            )
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            onItemSelected()
        }
    }
}
