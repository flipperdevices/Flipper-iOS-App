import Core
import SwiftUI

struct StressTestView: View {
    @StateObject var viewModel: StressTestViewModel

    var body: some View {
        VStack {
            HStack {
                Text("success: \(viewModel.successCount)")
                Text("error: \(viewModel.errorCount)")
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            List(viewModel.events.reversed()) {
                Text($0.message)
                    .foregroundColor($0.color)
            }

            HStack {
                RoundedButton("Start") {
                    viewModel.start()
                }

                RoundedButton("Stop") {
                    viewModel.stop()
                }
            }
            .padding(.vertical, 20)
        }
        .navigationTitle("RPC Stress Test")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension RPCStressTest.Event {
    var color: Color {
        switch kind {
        case .info: return .primary
        case .debug: return .secondary
        case .success: return .green
        case .error: return .red
        }
    }
}
