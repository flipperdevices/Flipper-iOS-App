import SwiftUI

struct OptionsView: View {
    var body: some View {
        NavigationView {
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
            .navigationBarHidden(true)
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView()
    }
}
