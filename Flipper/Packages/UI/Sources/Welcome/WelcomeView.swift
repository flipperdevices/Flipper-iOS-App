import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            InstructionView()
                .customBackground(Color.background)
                .navigationTitle("")
                .navigationBarHidden(true)
        }
    }
}
