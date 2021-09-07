import SwiftUI

struct InstructionsView: View {
    let viewModel: InstructionsViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var displayingConnections = false

    init(viewModel: InstructionsViewModel = .init()) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 15) {
            Image("DeviceConnect")
                .padding(.top, 25)

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

            ZStack {

                VStack {}
                    .frame(width: 345, height: 345, alignment: .leading)
                    .background(colorScheme == .light ? Color.white : Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .secondary, radius: 5, x: 0, y: 0)

                Image("BTStep2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .shadow(color: .clear, radius: 0)
            }
            .frame(width: 345, height: 345, alignment: .leading)
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
