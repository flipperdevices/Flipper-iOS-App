import Core
import SwiftUI

struct PingView: View {
    @StateObject var pingTest: PingTest = .init()
    @Environment(\.dismiss) private var dismiss
    @State var entered: String = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("request timestamp: \(pingTest.requestTimestamp)")
                Spacer()
            }

            HStack {
                Text("response timestamp: \(pingTest.responseTimestamp)")
                Spacer()
            }

            HStack {
                Text("time: \(pingTest.time) ms")
                Spacer()
            }

            HStack {
                Text("throughput: \(pingTest.bytesPerSecond) bps")
                Spacer()
            }

            HStack {
                Text("payload size: \(Int(pingTest.payloadSize))")
                Spacer()
            }

            Slider(
                value: $pingTest.payloadSize,
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
                pingTest.sendPing()
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
