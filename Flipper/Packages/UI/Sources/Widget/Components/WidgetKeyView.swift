import Core
import SwiftUI

@MainActor
struct WidgetKeyView: View {
    let key: WidgetKey
    var state: WidgetKeyState

    var onSendPressed: () -> Void
    var onSendReleased: () -> Void
    var onEmulateTapped: () -> Void

    var color: Color {
        guard state != .disabled else {
            return .black8
        }
        switch key.kind {
        case .subghz: return .a1
        case .nfc, .rfid: return .a2
        default: return .clear
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    if key.kind == .subghz {
                        SendProgress()
                    } else {
                        EmulateProgress()
                    }
                }
                .opacity(state == .emulating ? 1 : 0)

                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                    .opacity(0)

                VStack(spacing: 2) {
                    key.kind.icon
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                        .frame(width: 20, height: 20)

                    Text(key.name.value)
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
            }

            if key.kind == .subghz {
                WidgetSendButton(
                    state: state,
                    onPress: onSendPressed,
                    onRelease: onSendReleased
                )
            } else {
                WidgetEmulateButton(
                    state: state,
                    onTapGesture: onEmulateTapped,
                    onLongPressGesture: onEmulateTapped
                )
            }
        }
    }
}
