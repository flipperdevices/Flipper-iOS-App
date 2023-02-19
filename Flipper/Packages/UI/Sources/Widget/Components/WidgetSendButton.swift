import SwiftUI

struct WidgetSendButton: View {
    let state: WidgetKeyState
    let onPress: () -> Void
    let onRelease: () -> Void

    @State private var isPressed = false

    var color: Color {
        state == .disabled ? .black8 : .a1
    }

    var label: String {
        state == .emulating ? "Sending..." : "Send"
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
        .disabled(state == .disabled)
    }
}
