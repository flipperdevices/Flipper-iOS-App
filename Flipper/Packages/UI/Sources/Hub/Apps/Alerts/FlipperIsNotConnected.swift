import SwiftUI

struct FlipperIsNotConnectedAlert: View {
    @Binding var isPresented: Bool

    @AppStorage(.selectedTabKey) var selectedTab: TabView.Tab = .device

    var body: some View {
        VStack(spacing: 0) {
            Image("AlertNotConnected")
                .padding(.top, 17)

            Text("Flipper is Not Connected")
                .font(.system(size: 14, weight: .bold))
                .padding(.top, 24)

            Text("Connect your Flipper Zero to install this app")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
                .padding(.horizontal, 12)
                .padding(.top, 4)

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
            .padding(.top, 24)
        }
    }
}
