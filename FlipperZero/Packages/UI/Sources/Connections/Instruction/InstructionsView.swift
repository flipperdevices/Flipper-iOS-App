import SwiftUI

struct InstructionsView: View {
    @StateObject var viewModel: InstructionsViewModel

    var body: some View {
        VStack(spacing: 10) {
            Image("DeviceConnect")
                .padding(.top, 15)

            Text(
                """
                Connect your Flipper
                """)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(
                """
                Activate Bluetooth in settings menu
                on your device.
                """)
                .font(.subheadline)
                .multilineTextAlignment(.center)

            InstructionsCarouselView()

            Spacer()

            RoundedButton("Search for flipper") {
                viewModel.presentConnectionsSheet = true
            }
            .sheet(isPresented: $viewModel.presentConnectionsSheet) {
                ConnectionsView(viewModel: .init())
                Spacer()
                Button("Skip connection") {
                    viewModel.presentConnectionsSheet = false
                    viewModel.presentWelcomeSheet = false
                }
                .padding(.bottom, onMac ? 140 : 20)
            }

            Button("Skip connection") {
                viewModel.presentWelcomeSheet = false
            }
            .padding(.vertical, 24)
        }
        .padding(.top, onMac ? 0 : 40)
        .edgesIgnoringSafeArea(.top)
    }
}
