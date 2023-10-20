import SwiftUI

extension EmulateView {
    struct SendButton: View {
        let isEmulating: Bool
        let emulateDuration: Int

        let onPressed: () -> Void
        let onReleased: () -> Void

        @Environment(\.isEnabled) var isEnabled

        @State private var isPressed = false
        @State private var trimFrom: Double = 0
        @State private var trimTo: Double = 0

        var text: String {
            isEmulating
                ? "Sending..."
                : "Send"
        }

        var buttonColor: Color {
            isEnabled
                ? isEmulating
                    ? sendingColor
                    : Color.a1
                : .black8
        }
        var sendingColor: Color {
            .init(.init(red: 1.0, green: 0.65, blue: 0.29, alpha: 1.0))
        }
        var borderBackgroundColor: Color {
            .init(.init(red: 0.99, green: 0.79, blue: 0.59, alpha: 1.0))
        }
        var borderColor: Color {
            .a1
        }

        var animationDuration: Double {
            Double(emulateDuration + 333) / 1000
        }

        func startAnimation() {
            guard !isEmulating else { return }
            trimTo = 0
            withAnimation(.linear(duration: animationDuration)) {
                trimTo = 1
            }
        }

        var body: some View {
            ZStack {
                HStack {
                    if isEmulating {
                        Animation("Sending")
                            .frame(width: 32, height: 32)
                    } else {
                        Image("Send")
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)

                HStack {
                    Spacer()
                    Text(text)
                        .font(.born2bSportyV2(size: 23))
                    Spacer()
                }
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(buttonColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderBackgroundColor, lineWidth: 4)
                    .opacity(isEmulating ? 1 : 0)
            )
            .overlay(
                SendBorder(cornerRadius: 12)
                    .trim(from: trimFrom, to: trimTo)
                    .stroke(borderColor, lineWidth: 4)
                    .opacity(isEmulating ? 1 : 0)
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else {
                            return
                        }
                        isPressed = true
                        onPressed()
                        if !isEmulating {
                            startAnimation()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onReleased()
                    }
            )
        }
    }
}
