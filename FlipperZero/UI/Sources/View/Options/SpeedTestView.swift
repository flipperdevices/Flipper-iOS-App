import SwiftUI

struct SpeedTestView: View {
    @ObservedObject var viewModel: SpeedTestViewModel
    @State var packetSize = Double(SpeedTestViewModel.defaultPacketSize)

    var body: some View {
        VStack {
            Spacer()
            Text(String("\(viewModel.rps) bytes per second"))
            Spacer()
            Text("Packet size: \(viewModel.packetSize)")
            Slider(
                value: $packetSize,
                in: (1 ... Double(SpeedTestViewModel.maximumPacketSize)),
                step: 1.0) {
                Text("Packet size")
            } minimumValueLabel: {
                Text("1")
            } maximumValueLabel: {
                Text(String(SpeedTestViewModel.maximumPacketSize))
            } onEditingChanged: { editing in
                viewModel.packetSize = Int(packetSize)
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
    }
}

struct SpeedTestView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedTestView(viewModel: .init())
    }
}
