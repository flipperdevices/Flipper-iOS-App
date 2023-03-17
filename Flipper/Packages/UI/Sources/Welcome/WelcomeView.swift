import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            InstructionView()
                .customBackground(Color.background)
                .navigationTitle("")
                .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}
