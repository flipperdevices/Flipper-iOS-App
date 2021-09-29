import SwiftUI

// swiftlint:disable multiline_arguments

struct PingView: View {
    @StateObject var viewModel: PingViewModel
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

            Button("Send ping") {
                viewModel.sendPing()
            }
            .padding(.top, 50)
        }
        .navigationTitle("Protobuf ping")
        .navigationBarTitleDisplayMode(.inline)
    }
}
