import Core
import SwiftUI

struct ConnectionRow: View {
    let flipper: Flipper
    let isConnecting: Bool
    var onConnectAction: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 6) {
                    Image("DeviceConnect")
                    Text("Flipper Zero")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.black30)
                }
                .padding(.horizontal, 14)

                Divider()

                Text(flipper.name)
                    .lineLimit(1)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.leading, 14)

                Spacer(minLength: 0)

                switch flipper.state {
                case .connecting, .connected:
                    ProgressView()
                        .padding(.trailing, 14)
                default:
                    Button {
                        if flipper.state != .connected {
                            onConnectAction()
                        }
                    } label: {
                        Text("Connect")
                            .font(.system(size: 12, weight: .bold))
                            .roundedButtonStyle(
                                height: 36,
                                horizontalPadding: 16)
                            .lineLimit(1)
                    }
                    .disabled(isConnecting)
                    .padding(.trailing, 14)
                }
            }
        }
        .background(Color.groupedBackground)
        .frame(height: 64)
        .cornerRadius(10)
        .shadow(color: .shadow, radius: 16, x: 0, y: 4)
    }
}
