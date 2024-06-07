import SwiftUI

struct AppsNotCompatibleFirmware: View {
    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

    var description: AttributedString {
        var string: AttributedString = "To access Apps, install the latest " +
            "firmware version from Release Channel on your Flipper"

        if let range = string.range(of: "Release") {
            string[range].foregroundColor = .sGreenUpdate
        }

        return string
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("Not Compatible with your Firmware")
                    .font(.system(size: 14, weight: .bold))

                Text(description)
                    .font(.system(size: 14, weight: .medium))
            }
            .multilineTextAlignment(.center)

            Button {
                selectedTab = .device
            } label: {
                Text("Go to Firmware Update")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.a2)
            }
        }
    }
}
