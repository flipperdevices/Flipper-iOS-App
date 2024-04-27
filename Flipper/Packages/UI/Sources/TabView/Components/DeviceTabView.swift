import Core
import SwiftUI

struct DeviceTabView: View {
    let status: Device.Status
    let isActiveTab: Bool

    private var deviceActionName: String {
        "device_" + status.iconName
    }

    var body: some View {
        ZStack {
            DeviceTabShape()
                .form(isFill: isActiveTab, status.color)

            Group {
                switch status {
                case .connecting, .synchronizing:
                    RotateAnimationImage(name: deviceActionName)

                default:
                    Image(deviceActionName)
                        .renderingMode(.template)
                }
            }
            .foregroundColor(isActiveTab ? .white : status.color)
            .offset(x: 1)
        }
        .frame(width: 42, height: 24)
    }
}

private struct RotateAnimationImage: View {
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
