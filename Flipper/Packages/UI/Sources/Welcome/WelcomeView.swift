import SwiftUI

struct WelcomeView: View {
    @StateObject var viewModel: WelcomeViewModel
    @Environment(\.backgroundColor) var backgroundColor

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
