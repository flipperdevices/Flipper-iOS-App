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

                ImportedBanner(itemName: viewModel.importedName)
                    .opacity(viewModel.importedOpacity)
            }

            TabView(
                selected: $viewModel.selectedTab,
                status: viewModel.status)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ImportedBanner: View {
    let itemName: String

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image("Done")
                VStack(alignment: .leading, spacing: 2) {
                    Text(itemName)
                        .lineLimit(1)
                        .font(.system(size: 12, weight: .bold))
                    Text("saved to Archive")
                        .font(.system(size: 12, weight: .medium))
                }
                Spacer()
            }
            .padding(12)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.black4)
            .cornerRadius(8)
        }
        .padding(12)
    }
}
