import SwiftUI

struct OptionsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Echo server") {
                    EchoView(viewModel: .init())
                }
                NavigationLink("Speedtest") {
                    SpeedTestView(viewModel: .init())
                }
            }
            .padding(.top, 300)
            .navigationBarHidden(true)
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView()
    }
}
