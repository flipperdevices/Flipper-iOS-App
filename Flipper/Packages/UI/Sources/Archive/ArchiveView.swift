import Core
import SwiftUI
import Combine

struct ArchiveView: View {
    @StateObject var viewModel: ArchiveViewModel

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.status == .connecting {
                    VStack(spacing: 4) {
                        Spinner()
                        Text("Connecting to Flipper...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black30)
                    }
                } else if viewModel.status == .synchronizing {
                    VStack(spacing: 4) {
                        Spinner()
                        Text(
                            viewModel.syncProgress == 0
                                ? "Syncing..."
                                : "Syncing \(viewModel.syncProgress)%"
                        )
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                    }
                } else {
                    RefreshableScrollView(
                        isEnabled: viewModel.canPullToRefresh,
                        action: viewModel.refresh
                    ) {
                        CategoryCard(
                            groups: viewModel.groups,
                            deletedCount: viewModel.deleted.count
                        )
                        .padding(14)

                        if !viewModel.favoriteItems.isEmpty {
                            FavoritesSection(viewModel: viewModel)
                                .padding(.horizontal, 14)
                                .padding(.bottom, 14)
                        }

                        if !viewModel.items.isEmpty {
                            AllItemsSection(viewModel: viewModel)
                                .padding(.horizontal, 14)
                                .padding(.bottom, 14)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LeadingToolbarItems {
                    Title("Archive")
                        .padding(.leading, 8)
                }
                TrailingToolbarItems {
                    SearchButton {
                        viewModel.showSearchView = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.showInfoView) {
                InfoView(viewModel: .init(item: viewModel.selectedItem))
            }
            .sheet(isPresented: $viewModel.hasImportedItem) {
                ImportView(viewModel: .init(url: viewModel.importedItem))
            }
            .fullScreenCover(isPresented: $viewModel.showSearchView) {
                ArchiveSearchView(viewModel: .init())
            }
            .fullScreenCover(isPresented: $viewModel.showWidgetSettings) {
                WidgetSettingsView(viewModel: .init())
            }
            .navigationTitle("")
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .a1)
    }
}

extension ArchiveView {
    struct FavoritesSection: View {
        @StateObject var viewModel: ArchiveViewModel

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Favorites")
                        .font(.system(size: 16, weight: .bold))
                    Image("StarFilled")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.sYellow)
                }

                CompactList(items: viewModel.favoriteItems) { item in
                    viewModel.onItemSelected(item: item)
                }
            }
        }
    }

    struct AllItemsSection: View {
        @StateObject var viewModel: ArchiveViewModel

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("All")
                        .font(.system(size: 16, weight: .bold))
                }

                CompactList(items: viewModel.sortedItems) { item in
                    viewModel.onItemSelected(item: item)
                }
            }
        }
    }
}
