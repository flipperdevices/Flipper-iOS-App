import SwiftUI

struct AppsOutdatedFlipperAlert: View {
    @Binding var isPresented: Bool

    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

    var message: AttributedString {
        var string = AttributedString(
            "This app requires the latest Flipper firmware version " +
            "from Release channel"
        )
        if let range = string.range(of: "Release") {
            string[range].foregroundColor = .sGreenUpdate
        }
        return string
    }

    var body: some View {
        VStack(spacing: 24) {
            Image("AppAlertUnsupported")
                .padding(.top, 17)

            VStack(spacing: 4) {
                Text("To install, update firmware from Release Channel")
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.center)

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
                Text("Go to Firmware Update")
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
