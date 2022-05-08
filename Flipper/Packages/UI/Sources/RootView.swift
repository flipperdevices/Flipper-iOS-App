import SwiftUI

public struct RootView: View {
    @ObservedObject var viewModel: RootViewModel

    public init(viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            if viewModel.isFirstLaunch {
                WelcomeView(viewModel: .init())
            } else {
                MainView(viewModel: .init())
            }
        }
        .onOpenURL { url in
            viewModel.onOpenURL(url)
        }
        .onContinueUserActivity("PlayAlertIntent") { _ in
            viewModel.playAlert()
        }
        .pairingIssueAlert(isPresented: $viewModel.isPairingIssue)
    }
}
