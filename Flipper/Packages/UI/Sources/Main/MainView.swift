import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel

    var body: some View {
        VStack {
            ZStack {
                DeviceView(viewModel: .init())
                    .opacity(viewModel.selectedTab == .device ? 1 : 0)
                ArchiveView(viewModel: .init { isEditing in
                    viewModel.isTabViewHidden = isEditing
                })
                .opacity(viewModel.selectedTab == .archive ? 1 : 0)
                OptionsView(viewModel: .init())
                    .opacity(viewModel.selectedTab == .options ? 1 : 0)
            }

            if !viewModel.isTabViewHidden {
                CustomTabView(selected: $viewModel.selectedTab)
            }
        }
        .addPartialSheet()
        .edgesIgnoringSafeArea(.bottom)
    }
}