import Core
import SwiftUI

struct OptionsView: View {
    @StateObject var viewModel: OptionsViewModel

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Utils")) {
                    NavigationLink("Ping") {
                        PingView(viewModel: .init())
                    }
                    NavigationLink("Stress Test") {
                        StressTestView(viewModel: .init())
                    }
                    NavigationLink("Speed Test") {
                        SpeedTestView(viewModel: .init())
                    }
                    NavigationLink("Logs") {
                        LogsView(viewModel: .init())
                    }
                }
                .disabled(!viewModel.supported)

                Section(header: Text("Remote")) {
                    NavigationLink("Screen Streaming") {
                        RemoteContolView(viewModel: .init())
                    }
                    NavigationLink("File Manager") {
                        FileManagerView(viewModel: .init())
                    }
                    Button("Play Alert") {
                        viewModel.playAlert()
                    }
                    Button("Reboot Flipper") {
                        viewModel.rebootFlipper()
                    }
                }
                .disabled(!viewModel.supported)

                Section(header: Text("Danger")) {
                    Button("Reset App") {
                        viewModel.resetApp()
                    }
                    .foregroundColor(.red)

                    Button("Unpair Flipper") {
                        viewModel.unpairFlipper()
                    }
                    .foregroundColor(.red)
                }
                .disabled(!viewModel.supported)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Options")
                        .font(.system(size: 20, weight: .bold))
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .header)
    }
}
