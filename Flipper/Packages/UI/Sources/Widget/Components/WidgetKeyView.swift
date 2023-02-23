import Core
import SwiftUI

@MainActor
struct WidgetKeyView: View {
    @EnvironmentObject var widget: TodayWidget

    let key: WidgetKey

    var isEmulating: Bool {
        widget.keyToEmulate == key
    }

    var isEnabled: Bool {
        widget.keyToEmulate == nil || isEmulating
    }

    var color: Color {
        guard isEnabled else {
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
                .opacity(isEmulating ? 1 : 0)

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
                    isEmulating: isEmulating,
                    onPress: { widget.onSendPressed(for: key) },
                    onRelease: { widget.onSendReleased(for: key) }
                )
            } else {
                WidgetEmulateButton(
                    isEmulating: isEmulating,
                    onTapGesture: { widget.onEmulateTapped(for: key) },
                    onLongPressGesture: { widget.onEmulateTapped(for: key) }
                )
            }
        }
        .disabled(!isEnabled)
    }
}
