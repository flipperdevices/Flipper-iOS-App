import SwiftUI

struct NotSupportedFeatureAlert: View {
    @Binding var isPresented: Bool

    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

    var body: some View {
        VStack(spacing: 24) {
            Image("OutdatedFirmware")
                .padding(.top, 16)

            VStack(spacing: 4) {
                Text("Flipper Firmware Not Supported")
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("This feature requires the " +
                     "latest Flipper firmware version")
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
