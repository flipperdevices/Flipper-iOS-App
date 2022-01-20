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
                }

                Section(header: Text("Archive")) {
                    NavigationLink("Deleted Items") {
                        ArchiveBinView(viewModel: .init())
                    }
                }

                Section(header: Text("Remote")) {
                    if viewModel.canPlayAlert {
                        Button("Play Alert") {
                            Task {
                                try await RPC.shared.playAlert()
                            }
                        }
                    }
                    Button("Reboot Flipper") {
                        Task {
                            try await RPC.shared.reboot(to: .os)
                        }
                    }
                }

                Section(header: Text("Danger")) {
                    Button("Reset App") {
                        viewModel.resetApp()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
