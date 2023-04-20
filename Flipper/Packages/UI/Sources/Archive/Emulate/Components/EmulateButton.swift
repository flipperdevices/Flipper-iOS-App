import SwiftUI

extension EmulateView {
    struct EmulateButton: View {
        @Environment(\.isEnabled) var isEnabled

        let isEmulating: Bool
        let onTapGesture: () -> Void
        let onLongTapGesture: () -> Void

        @State private var trimFrom: Double = 0
        @State private var trimTo: Double = 0.333

        var text: String {
            isEmulating
                ? "Emulating..."
                : "Emulate"
        }

        var buttonColor: Color {
            isEnabled
                ? isEmulating
                    ? .init(.init(red: 0.54, green: 0.73, blue: 1.0, alpha: 1.0))
                    : Color.a2
                : .black8
        }
        var borderBackgroundColor: Color {
            .init(.init(red: 0.73, green: 0.84, blue: 0.99, alpha: 1.0))
        }
        var borderColor: Color {
            .a2
        }

        func startAnimation() {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                trimFrom = 0.667
                trimTo = 1
            }
        }

        var body: some View {
            ZStack {
                HStack {
                    if isEmulating {
                        Animation("Emulating")
                            .frame(width: 32, height: 32)
                    } else {
                        Image("Emulate")
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
                EmulateBorder(cornerRadius: 12)
                    .trim(from: trimFrom, to: trimTo)
                    .stroke(borderColor, lineWidth: 4)
                    .opacity(isEmulating ? 1 : 0)
            )
            .simultaneousGesture(LongPressGesture().onEnded { _ in
                onLongTapGesture()
            })
            .simultaneousGesture(TapGesture().onEnded {
                onTapGesture()
            })
            .onAppear {
                startAnimation()
            }
        }
    }
}
