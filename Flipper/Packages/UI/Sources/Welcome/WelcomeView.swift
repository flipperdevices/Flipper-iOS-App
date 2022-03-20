import SwiftUI

struct WelcomeView: View {
    @StateObject var viewModel: WelcomeViewModel

    var body: some View {
        NavigationView {
            InstructionView(viewModel: .init())
                .customBackground(Color.background)
                .navigationTitle("")
                .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}
