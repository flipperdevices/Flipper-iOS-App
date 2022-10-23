import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    @StateObject var tabViewController: TabViewController = .init()

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                DeviceView(viewModel: .init())
                    .opacity(viewModel.selectedTab == .device ? 1 : 0)
                ArchiveView(viewModel: .init())
                    .opacity(viewModel.selectedTab == .archive ? 1 : 0)
                HubView(viewModel: .init())
                    .opacity(viewModel.selectedTab == .hub ? 1 : 0)

                ImportedBanner(itemName: viewModel.importedName)
                    .opacity(viewModel.importedOpacity)
            }

            if !tabViewController.isHidden {
                TabView(
                    viewModel: .init(),
                    selected: $viewModel.selectedTab
                )
                .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .environmentObject(tabViewController)
    }
}

struct ImportedBanner: View {
    let itemName: String
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .light ? .black4 : .black80
    }

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
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .padding(12)
    }
}
