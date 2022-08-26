import SwiftUI

struct EmulateView: View {
    @StateObject var viewModel: EmulateViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 4) {
            switch viewModel.item.fileType {
            case .nfc, .rfid, .ibutton:
                EmulateButton(viewModel: viewModel)
                    .disabled(!viewModel.isConnected)
                EmulateDescription("Emulating on Flipper... Tap to stop")
                    .opacity(viewModel.isEmulating ? 1 : 0)
            case .subghz:
                SendButton(viewModel: viewModel)
                    .disabled(!viewModel.isConnected)
                EmulateDescription("Hold to send from Flipper")
                    .opacity(viewModel.isEmulating ? 0 : 1)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, viewModel.isEmulating ? 18 : 24)
        .padding(.top, 18)
        .alert(
            "Another app is running",
            isPresented: $viewModel.isFlipperAppSystemLocked
        ) {
        } message: {
            Text("Press ↩️ button on your Flipper")
        }
        .onDisappear {
            viewModel.stopEmulate()
        }
    }
}

struct EmulateButton: View {
    @ObservedObject var viewModel: EmulateViewModel
    @Environment(\.isEnabled) var isEnabled

    var text: String {
        viewModel.isEmulating
            ? "Emulating..."
            : "Emulate"
    }

    var color1 = Color(red: 0.65, green: 0.82, blue: 1.0, opacity: 1.0)
    var color2 = Color(red: 0.35, green: 0.62, blue: 1.0, opacity: 1.0)

    var body: some View {
        HStack(spacing: 4) {
            if viewModel.isEmulating {
                Animation("Emulating")
                    .frame(width: 32, height: 32)
            } else {
                Image("Emulate")
            }
            Text(text)
                .font(.born2bSportyV2(size: 23))
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, viewModel.isEmulating ? 0 : 6)
        .foregroundColor(.white)
        .background {
            if !isEnabled {
                Color.black8
            } else if viewModel.isEmulating {
                AnimatedPlaceholder(color1: color1, color2: color2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Color.a2
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEnabled ? Color.a2 : .black8, lineWidth: 2))
        .simultaneousGesture(LongPressGesture().onEnded { _ in
            viewModel.toggleEmulate()
        })
        .simultaneousGesture(TapGesture().onEnded {
            viewModel.toggleEmulate()
        })
    }
}

struct SendButton: View {
    @ObservedObject var viewModel: EmulateViewModel
    @Environment(\.isEnabled) var isEnabled

    var text: String {
        viewModel.isEmulating
            ? "Sending..."
            : "Send"
    }

    var color1 = Color(red: 1.0, green: 0.71, blue: 0.0, opacity: 1.0)
    var color2 = Color(red: 1.0, green: 0.51, blue: 0.0, opacity: 1.0)

    var body: some View {
        HStack(spacing: 4) {
            if viewModel.isEmulating {
                Animation("Sending")
                    .frame(width: 32, height: 32)
            } else {
                Image("Send")
            }

            Text(text)
                .font(.born2bSportyV2(size: 23))
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, viewModel.isEmulating ? 0 : 6)
        .foregroundColor(.white)
        .background {
            if !isEnabled {
                Color.black8
            } else if viewModel.isEmulating {
                AnimatedPlaceholder(color1: color1, color2: color2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Color.a1
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEnabled ? Color.a1 : .black8, lineWidth: 2))
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    viewModel.startEmulate()
                }
                .onEnded { _ in
                    viewModel.stopEmulate()
                }
        )
    }
}

struct EmulateDescription: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.black20)
    }
}
