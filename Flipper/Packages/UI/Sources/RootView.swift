import Core
import SwiftUI

public struct RootView: View {
    @ObservedObject var viewModel: RootViewModel
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .dark ? .backgroundDark : .backgroundLight
    }

    public init(viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            if viewModel.isFirstLaunch {
                NavigationView {
                    InstructionView(viewModel: .init())
                        .customBackground(backgroundColor)
                }
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
