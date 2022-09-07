import SwiftUI

struct EmulateView: View {
    @StateObject var viewModel: EmulateViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 4) {
            switch viewModel.item.kind {
            case .nfc, .rfid, .ibutton:
                EmulateButton(viewModel: viewModel)
                    .disabled(viewModel.status != .connected)
                EmulateDescription(viewModel: viewModel)
            case .subghz:
                SendButton(viewModel: viewModel)
                    .disabled(viewModel.status != .connected)
                EmulateDescription(viewModel: viewModel)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, viewModel.isEmulating ? 18 : 24)
        .padding(.top, 18)
        .customAlert(isPresented: $viewModel.isFlipperAppSystemLocked) {
            FlipperBusyAlert(isPresented: $viewModel.isFlipperAppSystemLocked)
        }
        .onDisappear {
            viewModel.forceStopEmulate()
        }
    }
}

struct EmulateButton: View {
    @ObservedObject var viewModel: EmulateViewModel
    @Environment(\.isEnabled) var isEnabled

    @State var trimFrom: Double = 0
    @State var trimTo: Double = 0.333

    var text: String {
        viewModel.isEmulating
            ? "Emulating..."
            : "Emulate"
    }

    var buttonColor: Color {
        isEnabled
            ? viewModel.isEmulating
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
                if viewModel.isEmulating {
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
        .padding(.horizontal, viewModel.isEmulating ? 0 : 6)
        .foregroundColor(.white)
        .background(buttonColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderBackgroundColor, lineWidth: 4)
                .opacity(viewModel.isEmulating ? 1 : 0)
        }
        .overlay(
            EmulateBorder(cornerRadius: 12)
                .trim(from: trimFrom, to: trimTo)
                .stroke(borderColor, lineWidth: 4)
                .opacity(viewModel.isEmulating ? 1 : 0)
        )
        .simultaneousGesture(LongPressGesture().onEnded { _ in
            viewModel.toggleEmulate()
        })
        .simultaneousGesture(TapGesture().onEnded {
            viewModel.toggleEmulate()
        })
        .onAppear {
            startAnimation()
        }
    }
}

struct SendButton: View {
    @ObservedObject var viewModel: EmulateViewModel
    @Environment(\.isEnabled) var isEnabled

    @State var trimFrom: Double = 0
    @State var trimTo: Double = 0

    var text: String {
        viewModel.isEmulating
            ? "Sending..."
            : "Send"
    }

    var buttonColor: Color {
        isEnabled
            ? viewModel.isEmulating
                ? .init(.init(red: 1.0, green: 0.65, blue: 0.29, alpha: 1.0))
                : Color.a1
            : .black8
    }
    var borderBackgroundColor: Color {
        .init(.init(red: 0.99, green: 0.79, blue: 0.59, alpha: 1.0))
    }
    var borderColor: Color {
        .a1
    }

    var animationDuration: Double {
        viewModel.item.isRaw
            ? Double(viewModel.emulateRawMinimum + 333) / 1000
            : Double(viewModel.emulateMinimum + 333) / 1000
    }

    func startAnimation() {
        guard !viewModel.isEmulating else { return }
        trimTo = 0
        withAnimation(.linear(duration: animationDuration)) {
            trimTo = 1
        }
    }

    var body: some View {
        ZStack {
            HStack {
                if viewModel.isEmulating {
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
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderBackgroundColor, lineWidth: 4)
                .opacity(viewModel.isEmulating ? 1 : 0)
        }
        .overlay(
            SendBorder(cornerRadius: 12)
                .trim(from: trimFrom, to: trimTo)
                .stroke(borderColor, lineWidth: 4)
                .opacity(viewModel.isEmulating ? 1 : 0)
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if viewModel.isFlipperAppCancellation {
                        viewModel.forceStopEmulate()
                    } else {
                        startAnimation()
                        viewModel.startEmulate()
                    }
                }
                .onEnded { _ in
                    viewModel.stopEmulate()
                }
        )
    }
}

struct EmulateDescription: View {
    @StateObject var viewModel: EmulateViewModel

    var text: String {
        switch viewModel.status {
        case .connected:
            return viewModel.item.kind == .subghz ? sendText : emulateText
        case .connecting:
            return "Connecting..."
        case .synchronizing, .synchronized:
            return "Not synced. Unable to send from Flipper."
        default:
            return "Flipper Not Connected"
        }
    }

    var sendText: String {
        if viewModel.isEmulating {
            return ""
        } else {
            return "Tap to send from Flipper"
        }
    }

    var emulateText: String {
        if viewModel.isEmulating {
            return "Emulating on Flipper... Tap to stop"
        } else {
            return ""
        }
    }

    var image: String {
        "WarningSmall"
    }

    var isError: Bool {
        viewModel.status != .connected &&
        viewModel.status != .connecting
    }

    var body: some View {
        HStack(spacing: 4) {
            if isError {
                Image(image)
            }

            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.black20)
        }
    }
}
