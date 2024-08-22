import SwiftUI

struct InfraredChooseSignalSheet: View {
    @Environment(\.colorScheme) var colorScheme

    let message: String
    let onConfirm: (Bool) -> Void

    private var backgroundColor: Color {
        colorScheme == .light ? .white : .black88
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .padding(.top, 36)

            HStack {
                Text("No")
                    .foregroundColor(Color.a2)
                    .font(.system(size: 16, weight: .medium))
                    .onTapGesture { onConfirm(false) }

                Spacer()

                Text("Yes")
                    .foregroundColor(Color.white)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 36)
                    .padding(.vertical, 12)
                    .background(Color.a2)
                    .cornerRadius(30)
                    .onTapGesture { onConfirm(true) }
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 72)
        }
        .background(backgroundColor)
    }
}
