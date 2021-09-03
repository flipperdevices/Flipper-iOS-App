import SwiftUI

struct HomeView: View {
    @State private var displayingConnections = false

    var body: some View {
        VStack {
            Text("Hello, Flipper users!")
                .padding()
            Button("Connect your device") {
                self.displayingConnections = true
            }
            .sheet(isPresented: self.$displayingConnections) {
                ConnectionsView(viewModel: ConnectionsViewModel())
                #if os(macOS)
                HStack {
                    Spacer()
                    Button("Close") {
                        self.displayingConnections = false
                    }
                    .padding(.all)
                }
                #endif
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
