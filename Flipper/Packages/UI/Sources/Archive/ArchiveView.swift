import Core
import SwiftUI
import Combine

struct ArchiveView: View {
    @StateObject var viewModel: ArchiveViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                CategoryCard(
                    groups: viewModel.groups,
                    deletedCount: viewModel.deleted.count
                )
                .padding(14)

                if !viewModel.favoriteItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Favorites")
                                .font(.system(size: 16, weight: .bold))
                            Image("StarFilled")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.yellow)
                        }

                        CompactList(items: viewModel.favoriteItems) { item in
                            viewModel.onItemSelected(item: item)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                }

                if !viewModel.items.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("All")
                                .font(.system(size: 16, weight: .bold))
                        }

                        CompactList(items: viewModel.sortedItems) { item in
                            viewModel.onItemSelected(item: item)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                }
            }
            .background(Color.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Archive")
                        .font(.system(size: 20, weight: .bold))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showSearchView = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showInfoView) {
                InfoView(viewModel: .init(item: viewModel.selectedItem))
            }
            .sheet(isPresented: $viewModel.hasImportedItem) {
                ImportView(viewModel: .init(item: viewModel.importedItem))
            }
            .fullScreenCover(isPresented: $viewModel.showSearchView) {
                ArchiveSearchView(viewModel: .init())
            }
            .navigationTitle("")
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .header)
    }
}
