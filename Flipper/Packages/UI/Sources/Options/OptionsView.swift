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
                    Button("Migrate Sub-GHz keys") {
                        viewModel.migrateSubGHz()
                    }
                }

                Section(header: Text("Archive")) {
                    NavigationLink("Deleted Items") {
                        ArchiveBinView(viewModel: .init())
                    }
                }

                Section(header: Text("Remote")) {
                    if viewModel.canPlayAlert {
                        Button("Play Alert") {
                            viewModel.playAlert()
                        }
                    }
                    Button("Reboot Flipper") {
                        viewModel.rebootFlipper()
                    }
                }

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
            }
            .navigationBarHidden(true)
        }
    }
}
