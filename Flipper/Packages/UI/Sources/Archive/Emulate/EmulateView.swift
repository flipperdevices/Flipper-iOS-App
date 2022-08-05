import SwiftUI

struct EmulateView: View {
    @StateObject var viewModel: EmulateViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            switch viewModel.item.fileType {
            case .nfc, .rfid, .ibutton:
                EmulateButton(viewModel: viewModel)
            case .subghz:
                SendButton(viewModel: viewModel)
            default:
                EmptyView()
            }
        }
        .onDisappear {
            viewModel.stopEmulate()
        }
    }
}

struct EmulateButton: View {
    @ObservedObject var viewModel: EmulateViewModel

    var image: String {
        "Emulate"
    }

    var text: String {
        viewModel.isEmulating
            ? "Emulating..."
            : "Emulate"
    }

    var body: some View {
        Button {
            withoutAnimation {
                if viewModel.isEmulating {
                    viewModel.stopEmulate()
                } else {
                    viewModel.startEmulate()
                }
            }
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(image)
                    Text(text)
                        .font(.born2bSportyV2(size: 23))
                }
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background {
                    if !viewModel.isConnected {
                        Color.black8
                    } else if viewModel.isEmulating {
                        AnimatedPlaceholder(
                            color1: .init(red: 0.65, green: 0.82, blue: 1.0, opacity: 1.0),
                            color2: .init(red: 0.35, green: 0.62, blue: 1.0, opacity: 1.0)
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Color.a2
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.isConnected ? Color.a2 : .black8, lineWidth: 2))
                .disabled(!viewModel.isConnected)
                .padding(.horizontal, viewModel.isEmulating ? 18 : 24)
                .padding(.top, 18)
                Text("Emulating on Flipper... Tap to stop")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.black20)
                    .opacity(viewModel.isEmulating ? 1 : 0)
            }
        }
    }
}

struct SendButton: View {
    @ObservedObject var viewModel: EmulateViewModel

    var image: String {
        viewModel.isEmulating
            ? "Sending"
            : "Send"
    }

    var text: String {
        viewModel.isEmulating
            ? "Sending..."
            : "Send"
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(image)
                Text(text)
                    .font(.born2bSportyV2(size: 23))
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background {
                if !viewModel.isConnected {
                    Color.black8
                } else if viewModel.isEmulating {
                    AnimatedPlaceholder(
                        color1: .init(red: 1.0, green: 0.71, blue: 0.0, opacity: 1.0),
                        color2: .init(red: 1.0, green: 0.51, blue: 0.0, opacity: 1.0)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Color.a1
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(viewModel.isConnected ? Color.a1 : .black8, lineWidth: 2))
            .disabled(!viewModel.isConnected)
            .padding(.horizontal, viewModel.isEmulating ? 18 : 24)
            .padding(.top, 18)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        viewModel.startEmulate()
                    }
                    .onEnded { _ in
                        viewModel.stopEmulate()
                    })
            Text("Hold to send from Flipper")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.black20)
                .opacity(viewModel.isEmulating ? 0 : 1)
        }
    }
}
