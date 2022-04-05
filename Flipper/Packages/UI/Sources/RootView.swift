import Core
import Inject
import SwiftUI
import Peripheral

public struct RootView: View {
    @Inject var rpc: RPC
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
            Task { try? await rpc.playAlert() }
        }
    }
}
