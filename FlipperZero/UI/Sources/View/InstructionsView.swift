import SwiftUI

struct InstructionsView: View {
    let viewModel: InstructionsViewModel
    @State private var displayingConnections = false

    init(viewModel: InstructionsViewModel = .init()) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 30) {
            Image("DeviceConnect")
                .padding(.top, 45)

            Text(
                """
                Configure connection
                to your Flipper
                """)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(
                """
                In order to establish connection to the device
                you need to complete a few steps.
                """)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            HStack(spacing: 15) {
                Image(systemName: "iphone")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Grant access to Bluetooth.")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text(
                        """
                        We need to access to your phone’s
                        Bluetooth to confirm the connection
                        between your phone and Flipper device.
                        """)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 15)

            HStack(spacing: 15) {
                Image("Device")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Enable Bluetooth on Flipper device.")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text(
                        """
                        Activate Bluetooth in device’s settins menu.
                        An icon in statusbar should appear.
                        """)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            RoundedButton("Continue") {
                self.displayingConnections = true
            }
            .sheet(isPresented: self.$displayingConnections) {
                ConnectionsView(viewModel: .init())
                #if os(macOS)
                HStack {
                    Spacer()
                    Button("Close") {
                        self.displayingConnections = false
                    }
                    .padding(.all)
                }
                #endif
            }
        }
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
