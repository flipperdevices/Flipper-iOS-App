import SwiftUI

struct InstructionsView: View {
    let viewModel: InstructionsViewModel
    @State private var displayingConnections = false

    init(viewModel: InstructionsViewModel = .init()) {
        self.viewModel = viewModel
    }

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

            RoundedButton("Continue") {
                self.displayingConnections = true
            }
            .sheet(isPresented: self.$displayingConnections) {
                ConnectionsView(viewModel: .init())
                if onMac {
                    Button("Close") {
                        self.displayingConnections = false
                    }
                    .padding(.bottom, 120)
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.top, onMac ? 0 : 40)
        .edgesIgnoringSafeArea(.top)
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
