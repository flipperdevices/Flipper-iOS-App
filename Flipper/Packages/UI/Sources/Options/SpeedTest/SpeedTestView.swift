import SwiftUI

// swiftlint:disable vertical_parameter_alignment_on_call

struct SpeedTestView: View {
    @StateObject var viewModel: SpeedTestViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Spacer()
            Text(String("\(viewModel.bps) bytes per second"))
            Spacer()
            Text(String("\(viewModel.bpsMin) ~ \(viewModel.bpsMax) bps"))
            Spacer()
            Text("Packet size: \(Int(viewModel.packetSize))")
            Slider(
                value: $viewModel.packetSize,
                in: (1.0 ... Double(viewModel.maximumPacketSize)),
                step: 1.0
            ) {
                Text("Packet size")
            } minimumValueLabel: {
                Text("1")
            } maximumValueLabel: {
                Text(String(viewModel.maximumPacketSize))
            }
            Spacer()
            Button(viewModel.isRunning ? "Stop" : "Start") {
                switch viewModel.isRunning {
                case true:
                    viewModel.stop()
                case false:
                    viewModel.start()
                }
            }
            .padding(.bottom, 50)
        }
        .padding(14)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Speed Test")
            }
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}
