import SwiftUI

struct HomeView: View {
    @State private var displayingInstructions = false

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

            Button(action: { self.displayingInstructions = true }) {
                Text("I have Flipper device")
                    .fontWeight(.semibold)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 15)
            .sheet(isPresented: self.$displayingInstructions) {
                InstructionsView(viewModel: .init())
                #if os(macOS)
                HStack {
                    Spacer()
                    Button("Close") {
                        self.displayingInstructions = false
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
