import SwiftUI

struct DeviceDisconnectedAlert: View {
    @Binding var isPresented: Bool

    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

    var body: some View {
        VStack(spacing: 24) {
            Image("AppAlertNotConnected")
                .padding(.top, 16)

            VStack(spacing: 4) {
                Text("Flipper Not Connected")
                    .font(.system(size: 14, weight: .bold))

                Text("Connect your Flipper Zero to add remote")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
            }
            .padding(.horizontal, 12)

            Button {
                selectedTab = .device
                isPresented = false
            } label: {
                Text("Go to Connection")
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
