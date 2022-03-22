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
                    .disabled(!viewModel.isConnected)
                    NavigationLink("Stress Test") {
                        StressTestView(viewModel: .init())
                    }
                    .disabled(!viewModel.isConnected)
                    NavigationLink("Speed Test") {
                        SpeedTestView(viewModel: .init())
                    }
                    .disabled(!viewModel.isConnected)
                    NavigationLink("Logs") {
                        LogsView(viewModel: .init())
                    }
                }

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
                    .foregroundColor(viewModel.isConnected ? .accentColor : .gray)
                    Button("Reboot Flipper") {
                        viewModel.rebootFlipper()
                    }
                    .foregroundColor(viewModel.isConnected ? .accentColor : .gray)
                }
                .disabled(!viewModel.isConnected)

                Section(header: Text("Danger")) {
                    Button("Reset App") {
                        viewModel.resetApp()
                    }
                    .foregroundColor(.red)

                    Button("Unpair Flipper") {
                        viewModel.unpairFlipper()
                    }
                    .foregroundColor(viewModel.isConnected ? .red : .gray)
                    .disabled(!viewModel.isConnected)
                }
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
