import Core
import SwiftUI

struct InfraredFlipperNotConnectedError: View {
    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Image("AppAlertNotConnected")

                Text("Flipper Not Connected")
                    .font(.system(size: 12, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("Connect your Flipper to work with infrared")
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
            }

            Button {
                selectedTab = .device
            } label: {
                Text("Go to Connection")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.a2)
            }
        }
    }
}
