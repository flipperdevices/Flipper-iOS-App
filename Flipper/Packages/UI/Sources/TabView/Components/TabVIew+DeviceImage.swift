import Core
import SwiftUI

extension TabView {
    struct DeviceImage: View {
        let status: Device.Status
        let style: DeviceBase.Style

        private var deviceActionName: String {
            "device_" + status.iconName
        }

        var body: some View {
            ZStack {
                DeviceBase()
                    .paint(style: style, status.color)

                Group {
                    switch status {
                    case .connecting, .synchronizing:
                        RotatingImage(name: deviceActionName)

                    default:
                        Image(deviceActionName)
                            .renderingMode(.template)
                    }
                }
                .foregroundColor(style == .fill ? .white : status.color)
                .offset(x: 1)
            }
            .frame(width: 42, height: 24)
        }

        struct RotatingImage: View {
            @State private var isAnimating: Bool = false
            let name: String

            var body: some View {
                Image(name)
                    .renderingMode(.template)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 2)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                    .onAppear { isAnimating = true }
                    .onDisappear { isAnimating = false }
            }
        }
    }
}

private extension Device.Status {
    var iconName: String {
        switch self {
        case .noDevice: "no_device"
        case .unsupported: "unsupported"
        case .outdatedMobile: "unsupported"
        case .connecting: "connecting"
        case .connected: "connected"
        case .disconnected: "disconnected"
        case .synchronizing: "syncing"
        case .synchronized: "synced"
        case .updating: "connecting"
        case .invalidPairing: "pairing_failed"
        case .pairingFailed: "pairing_failed"
        }
    }
}
