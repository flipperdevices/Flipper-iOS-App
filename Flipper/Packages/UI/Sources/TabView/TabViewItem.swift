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
                image
                    .overlay {
                        GeometryReader { proxy in
                            Circle()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.a1)
                                .opacity(hasNotification ? 1 : 0)
                                .offset(x: proxy.size.width - 6, y: -4)
                        }
                    }

                Text(name)
                    .font(.system(size: 10, weight: .bold))
            }
            .padding(.horizontal, 8)
            .frame(minWidth: 69, minHeight: 46)
            .background(
                isSelected
                    ? RoundedRectangle(cornerRadius: 8).fill(Color.black4)
                    : nil
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onItemSelected()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
