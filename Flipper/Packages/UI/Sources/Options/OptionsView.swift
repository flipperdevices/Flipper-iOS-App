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
                    .disabled(!viewModel.isOnline)
                    NavigationLink("Stress Test") {
                        StressTestView(viewModel: .init())
                    }
                    .disabled(!viewModel.isOnline)
                    NavigationLink("Speed Test") {
                        SpeedTestView(viewModel: .init())
                    }
                    .disabled(!viewModel.isOnline)
                    NavigationLink("Logs") {
                        LogsView(viewModel: .init())
                    }
                    Button("Backup Keys") {
                        viewModel.backupKeys()
                    }
                }

                Section(header: Text("Remote")) {
                    NavigationLink("Screen Streaming") {
                        RemoteContolView(viewModel: .init())
                    }
                    NavigationLink("File Manager") {
                        FileManagerView(viewModel: .init())
                    }
                    Button("Reboot Flipper") {
                        viewModel.rebootFlipper()
                    }
                    .foregroundColor(viewModel.isOnline ? .accentColor : .gray)
                }
                .disabled(!viewModel.isOnline)

                Section(header: Text("Danger")) {
                    Button("Reset App") {
                        viewModel.resetApp()
                    }
                    .foregroundColor(.sRed)

                    Button("Unpair Flipper") {
                        viewModel.unpairFlipper()
                    }
                    .foregroundColor(viewModel.isOnline ? .sRed : .gray)
                    .disabled(!viewModel.isOnline)
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
        .navigationBarColors(foreground: .primary, background: .a1)
    }
}
