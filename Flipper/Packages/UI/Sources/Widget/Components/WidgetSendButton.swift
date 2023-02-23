import SwiftUI

struct WidgetSendButton: View {
    let isEmulating: Bool
    let onPress: () -> Void
    let onRelease: () -> Void

    @State private var isPressed = false

    @Environment(\.isEnabled) var isEnabled

    var color: Color {
        isEnabled ? .a1 : .black8
    }

    var label: String {
        isEmulating ? "Sending..." : "Send"
    }

    var body: some View {
        HStack {
            Spacer()
            Text(label)
                .font(.born2bSportyV2(size: 22))
                .foregroundColor(.white)
            Spacer()
        }
        .frame(height: 45)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !isPressed else {
                        return
                    }
                    isPressed = true
                    onPress()
                }
                .onEnded { _ in
                    isPressed = false
                    onRelease()
                }
        )
    }
}
