import SwiftUI

struct WelcomeView: View {
    @StateObject var viewModel: WelcomeViewModel
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .dark ? .backgroundDark : .backgroundLight
    }

    var body: some View {
        NavigationView {
            InstructionView(viewModel: .init())
                .customBackground(backgroundColor)
                .navigationTitle("")
                .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}
