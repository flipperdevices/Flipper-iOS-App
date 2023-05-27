import SwiftUI

struct OutdatedFirmwareCard: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Card {
            VStack(spacing: 0) {
                Image("OutdatedFirmware")

                Text("Outdated firmware version")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                Text(
                    "Firmware version on your Flipper is not supported. " +
                    "Please update it via PC."
                )
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
                .padding(.top, 4)

                Button {
                    openURL(.helpToInstallFirmware)
                } label: {
                    Text("How to update Flipper")
                        .underline()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.a2)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
        }
    }
}
