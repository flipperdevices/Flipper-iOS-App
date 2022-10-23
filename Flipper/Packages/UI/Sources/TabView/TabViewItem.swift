import SwiftUI

struct TabViewItem: View {
    let image: AnyView
    let name: String
    let isSelected: Bool
    let hasNotification: Bool
    let onItemSelected: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    image
                        .padding(.top, 6)

                    Circle()
                        .frame(width: 12, height: 12)
                        .offset(x: -3, y: 3)
                        .foregroundColor(.a1)
                        .opacity(hasNotification ? 1 : 0)
                }

                Text(name)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.bottom, 4)
                    .padding(.horizontal, 12)
            }
            .frame(minWidth: 69)
            .background(isSelected ? Color.black4 : Color.clear)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .onTapGesture {
            onItemSelected()
        }
    }
}
