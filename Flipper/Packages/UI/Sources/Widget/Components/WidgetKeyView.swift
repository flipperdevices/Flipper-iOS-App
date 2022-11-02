import SwiftUI

@MainActor
struct WidgetKeyView: View {
    let index: Int
    var state: WidgetKeyState
    let viewModel: WidgetViewModel

    var key: WidgetKey { viewModel.keys[index] }

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
                    index: index,
                    state: state,
                    viewModel: viewModel)
            } else {
                WidgetEmulateButton(
                    index: index,
                    state: state,
                    viewModel: viewModel)
            }
        }
    }
}

@MainActor
struct WidgetSendButton: View {
    let index: Int
    let state: WidgetKeyState
    let viewModel: WidgetViewModel

    @State var isPressed = false

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
                    guard !viewModel.isEmulating else {
                        viewModel.forceStopEmulate()
                        return
                    }
                    viewModel.startEmulate(at: index)
                }
                .onEnded { _ in
                    isPressed = false
                    viewModel.stopEmulate()
                }
        )
        .disabled(state == .disabled)
    }
}

@MainActor
struct WidgetEmulateButton: View {
    let index: Int
    let state: WidgetKeyState
    let viewModel: WidgetViewModel

    var color: Color {
        state == .disabled ? .black8 : .a2
    }

    var label: String {
        state == .emulating ? "Emulating..." : "Emulate"
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
        .simultaneousGesture(LongPressGesture().onEnded { _ in
            viewModel.toggleEmulate(at: index)
        })
        .simultaneousGesture(TapGesture().onEnded {
            viewModel.toggleEmulate(at: index)
        })
        .disabled(state == .disabled)
    }
}
