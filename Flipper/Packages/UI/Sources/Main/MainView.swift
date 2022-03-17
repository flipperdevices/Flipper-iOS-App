import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                DeviceView(viewModel: .init())
                    .opacity(viewModel.selectedTab == .device ? 1 : 0)
                ArchiveView(viewModel: .init())
                    .opacity(viewModel.selectedTab == .archive ? 1 : 0)
                OptionsView(viewModel: .init())
                    .opacity(viewModel.selectedTab == .options ? 1 : 0)
            }

            TabView(
                selected: $viewModel.selectedTab,
                status: viewModel.status)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
