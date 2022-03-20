import Core
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
            Task { await viewModel.onOpenURL(url) }
        }
        .onContinueUserActivity("PlayAlertIntent") { _ in
            Task { try? await RPC.shared.playAlert() }
        }
    }
}
