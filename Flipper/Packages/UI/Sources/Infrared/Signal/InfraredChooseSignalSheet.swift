import Core
import SwiftUI

struct InfraredChooseSignalSheet: View {
    @Environment(\.colorScheme) var colorScheme

    let message: String
    let onConfirm: (InfraredChooseSignalType) -> Void

    private var backgroundColor: Color {
        colorScheme == .light ? .white : .black88
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(message)
                .font(.system(size: 16, weight: .medium))

            HStack {
                Text("No")
                    .foregroundColor(Color.a2)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 36)
                    .padding(.vertical, 12)
                    .onTapGesture { onConfirm(.failed) }

                Spacer()

                Text("Yes")
                    .foregroundColor(Color.white)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 36)
                    .padding(.vertical, 12)
                    .background(Color.a2)
                    .cornerRadius(30)
                    .onTapGesture { onConfirm(.success) }
            }
            .padding(.top, 24)
            .padding(.horizontal, 36)

            Text("Skip")
                .padding(.top, 12)
                .padding(.bottom, onMac ? 24 : 0)
                .foregroundColor(Color.a2)
                .font(.system(size: 16, weight: .medium))
                .onTapGesture { onConfirm(.skipped) }
        }
        .padding(.top, 24)
        .background(backgroundColor)
    }
}

#Preview {
    InfraredChooseSignalSheet(message: "Test Message") { _ in }
        .frame(height: 150)
}
