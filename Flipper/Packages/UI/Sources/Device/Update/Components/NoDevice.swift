import SwiftUI

extension DeviceUpdateView {
    struct NoDeviceView: View {
        @Environment(\.openURL) private var openURL

        var body: some View {
            VStack(spacing: 0) {
                Image("NoDeviceAlert")

                Text("Can’t connect to Flipper")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("1.")
                        Text("Check Bluetooth connection with Flipper")
                    }
                    HStack {
                        Text("2.")
                        Text("Make sure Flipper is Turned On")
                    }
                    HStack(alignment: .top) {
                        Text("3.")
                        Text(
                            "If Flipper doesn’t respond, reboot it and " +
                            "connect to the app via Bluetooth")
                    }
                    HStack {
                        Text("4.")
                        Text("Restart firmware update")
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black30)
                .padding(.top, 14)

                Button {
                    openURL(.helpToReboot)
                } label: {
                    Text("Read More")
                        .font(.system(size: 14, weight: .medium))
                        .underline()
                }
                .padding(.top, 14)
            }
            .padding(.top, 38)
            .padding(.horizontal, 24)
        }
    }
}
