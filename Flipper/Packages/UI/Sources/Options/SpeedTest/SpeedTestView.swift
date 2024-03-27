import Core
import SwiftUI

struct SpeedTestView: View {
    // next step
    @StateObject var speedTest: SpeedTest = Dependencies.shared.speedTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Spacer()
            Text(String("\(speedTest.bps) bytes per second"))
            Spacer()
            Text(String("\(speedTest.bpsMin) ~ \(speedTest.bpsMax) bps"))
            Spacer()
            Text("Packet size: \(Int(speedTest.packetSize))")
            Slider(
                value: $speedTest.packetSize,
                in: (1.0 ... Double(speedTest.maximumPacketSize)),
                step: 1.0
            ) {
                Text("Packet size")
            } minimumValueLabel: {
                Text("1")
            } maximumValueLabel: {
                Text(String(speedTest.maximumPacketSize))
            }
            Spacer()
            Button(speedTest.isRunning ? "Stop" : "Start") {
                switch speedTest.isRunning {
                case true:
                    speedTest.stop()
                case false:
                    speedTest.start()
                }
            }
            .padding(.bottom, 50)
        }
        .padding(14)
        .navigationBarBackground(Color.a1)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }
            PrincipalToolbarItems(alignment: .leading) {
                Title("Speed Test")
            }
        }
        .onDisappear {
            speedTest.stop()
        }
    }
}
