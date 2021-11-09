import SwiftUI

public struct RootView: View {
    @ObservedObject var viewModel: RootViewModel

    public init(viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            ZStack {
                DeviceView(viewModel: .init())
                    .opacity(viewModel.selectedTab == .device ? 1 : 0)
                ArchiveView(viewModel: .init { isEditing in
                    viewModel.isTabViewHidden = isEditing
                })
                .opacity(viewModel.selectedTab == .archive ? 1 : 0)
                OptionsView()
                    .opacity(viewModel.selectedTab == .options ? 1 : 0)
            }

            if !viewModel.isTabViewHidden {
                CustomTabView(selected: $viewModel.selectedTab)
            }
        }
        .addPartialSheet()
        .edgesIgnoringSafeArea(.bottom)
        .environmentObject(SheetManager.shared)
        .opacity(viewModel.isFirstLaunch ? 0 : 1)
        // swiftlint:disable multiline_arguments
        .sheet(isPresented: $viewModel.presentWelcomeSheet) {
            viewModel.isFirstLaunch = false
        } content: {
            InstructionsView(viewModel: .init($viewModel.presentWelcomeSheet))
        }
        .onOpenURL(perform: viewModel.importKey)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(viewModel: .init())
    }
}
