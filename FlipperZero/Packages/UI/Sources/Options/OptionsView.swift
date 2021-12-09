import Core
import SwiftUI

struct OptionsView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink("Protobuf ping") {
                        PingView(viewModel: .init())
                    }
                    NavigationLink("RPC Stress Test") {
                        StressTestView(viewModel: .init())
                    }
                    NavigationLink("RPC Speed Test") {
                        RPCSpeedTestView(viewModel: .init())
                    }
                }

                Button("Reboot Flipper") {
                    Task {
                        try await RPC.shared.reboot(to: .os)
                    }
                }
                .padding(.bottom, 100)
            }
            .navigationBarHidden(true)
        }
    }
}
