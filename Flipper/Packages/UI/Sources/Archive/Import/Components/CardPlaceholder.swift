import SwiftUI

extension ImportView {
    struct CardPlaceholder: View {
        @Environment(\.colorScheme) var colorScheme

        var dividerColor: Color {
            colorScheme == .dark ? .black60 : .black4
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 18) {
                AnimatedPlaceholder()
                    .frame(width: 114, height: 44)
                    .cornerRadius(18, corners: [.bottomRight])
                    .offset(x: -4, y: -4)

                VStack(alignment: .leading, spacing: 14) {
                    AnimatedPlaceholder()
                        .frame(width: 128, height: 16)
                    AnimatedPlaceholder()
                        .frame(width: 96, height: 12)
                }
                .padding(.horizontal, 12)

                Divider()
                    .frame(height: 1)
                    .background(dividerColor)

                VStack(alignment: .leading, spacing: 14) {
                    AnimatedPlaceholder()
                        .frame(width: 64, height: 12)
                    AnimatedPlaceholder()
                        .frame(width: 64, height: 12)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 18)
            }
            .background(Color.groupedBackground)
            .cornerRadius(16)
            .shadow(color: .shadow, radius: 16, x: 0, y: 4)
        }
    }
}
