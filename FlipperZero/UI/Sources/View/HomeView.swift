import SwiftUI

struct HomeView: View {
    @State private var displayingConnections = false

    var body: some View {
        VStack(spacing: 30) {
            Image("WelcomeImage")
                .padding(.top, 50)

            Text(
                """
                Welcome to the Flipper
                companion.
                """)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .font(.title)

            Text(
                """
                This app helps mantaining your Flipper device
                and managing data on device and in cloud.
                Also you can use this app without the device or
                cloud profile.
                """)
                .multilineTextAlignment(.center)
                .font(.subheadline)

            Spacer()

            Button(action: { self.displayingConnections = true }) {
                Text("I have Flipper device")
                    .fontWeight(.semibold)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 15)
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

            Button(action: {}) {
                Text("I just wanna look")
                    .fontWeight(.semibold)
            }
            .padding(.bottom, 15)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
