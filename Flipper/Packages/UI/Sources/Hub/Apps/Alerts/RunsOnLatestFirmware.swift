import SwiftUI

struct RunsOnLatestFirmwareAlert: View {
    @Binding var isPresented: Bool

    @AppStorage(.selectedTabKey) var selectedTab: TabView.Tab = .device

    var message: AttributedString {
        var string = AttributedString(
            "Connect your Flipper with latest firmware Release " +
            "version to install this app"
        )
        if let range = string.range(of: "Release") {
            string[range].foregroundColor = .sGreenUpdate
        }
        return string
    }

    var body: some View {
        VStack(spacing: 24) {
            Image("AppAlertNotConnected")
                .padding(.top, 17)

            VStack(spacing: 4) {
                Text("Runs on Latest Firmware Release")
                    .font(.system(size: 14, weight: .bold))

                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)

            }
            .padding(.horizontal, 12)

            Button {
                selectedTab = .device
                isPresented = false
            } label: {
                Text("Go to Device Screen")
                    .frame(height: 41)
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .background(Color.a2)
                    .cornerRadius(30)
            }
        }
    }
}
