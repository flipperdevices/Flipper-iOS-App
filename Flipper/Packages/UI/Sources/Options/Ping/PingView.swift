import SwiftUI

struct PingView: View {
    @StateObject var viewModel: PingViewModel
    @Environment(\.dismiss) private var dismiss
    @State var entered: String = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("request timestamp: \(viewModel.requestTimestamp)")
                Spacer()
            }

            HStack {
                Text("response timestamp: \(viewModel.responseTimestamp)")
                Spacer()
            }

            HStack {
                Text("time: \(viewModel.time) ms")
                Spacer()
            }

            HStack {
                Text("throughput: \(viewModel.bytesPerSecond) bps")
                Spacer()
            }

            HStack {
                Text("payload size: \(Int(viewModel.payloadSize))")
                Spacer()
            }

            Slider(
                value: $viewModel.payloadSize,
                in: (0...1024),
                step: 1
            ) {
                Text("Packet size")
            } minimumValueLabel: {
                Text("1")
            } maximumValueLabel: {
                Text(String(1024))
            }
            .padding(.vertical, 30)

            Button("Send ping") {
                viewModel.sendPing()
            }
        }
        .padding(14)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Ping")
            }
        }
    }
}
