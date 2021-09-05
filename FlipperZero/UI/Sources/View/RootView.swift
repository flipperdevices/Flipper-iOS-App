import SwiftUI

public struct RootView: View {
    let viewModel: RootViewModel

    public init(viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        WelcomeView()
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(viewModel: .init())
    }
}
