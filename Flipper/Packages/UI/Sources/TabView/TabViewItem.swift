import SwiftUI

struct TabViewItem: View {
    let image: AnyView
    let name: String
    let isSelected: Bool
    let hasNotification: Bool
    let onItemSelected: () -> Void

    struct Badge: View {
        var body: some View {
            Circle()
                .frame(width: 12, height: 12)
                .foregroundColor(.white)
                .overlay(alignment: .center) {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.sGreenUpdate)
                }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                image
                    .overlay {
                        GeometryReader { proxy in
                            Badge()
                                .opacity(hasNotification ? 1 : 0)
                                .offset(x: proxy.size.width - 6, y: -4)
                        }
                    }

                Text(name)
                    .lineLimit(1)
                    .font(.system(size: 10, weight: .bold))
            }
            .padding(.horizontal, 7)
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
