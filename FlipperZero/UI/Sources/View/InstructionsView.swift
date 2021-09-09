import SwiftUI

struct InstructionsView: View {
    let viewModel: InstructionsViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var displayingConnections = false

    init(viewModel: InstructionsViewModel = .init()) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 10) {
            Image("DeviceConnect")
                .padding(.top, 15)

            Text(
                """
                Connect your Flipper
                """)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(
                """
                Activate Bluetooth in settings menu
                on your device.
                """)
                .font(.subheadline)
                .multilineTextAlignment(.center)

            VStack {
                Image("BTStep2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .shadow(color: .clear, radius: 0)
            }
            .background(colorScheme == .light ? Color.white : Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .secondary, radius: 5, x: 0, y: 0)
            .padding(.horizontal, 20)
            .padding(.top, 5)

            HStack {
                Dot(isSelected: false)
                Dot(isSelected: true)
                Dot(isSelected: false)
            }

            Spacer()

            RoundedButton("Continue") {
                self.displayingConnections = true
            }
            .sheet(isPresented: self.$displayingConnections) {
                ConnectionsView(viewModel: .init())
                if onMac {
                    Button("Close") {
                        self.displayingConnections = false
                    }
                    .padding(.bottom, 120)
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.top, onMac ? 0 : 40)
        .edgesIgnoringSafeArea(.top)
    }
}

struct Dot: View {
    let isSelected: Bool

    var body: some View {
        ZStack { }
            .frame(width: 7, height: 7)
            .background(isSelected ? Color.primary : Color.secondary)
            .clipShape(Circle())
    }
}
struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
