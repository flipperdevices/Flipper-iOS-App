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
                    deleted: viewModel.deleted
                )
                .padding(14)

                CompactList(name: "All", items: viewModel.items)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
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
            .fullScreenCover(isPresented: $viewModel.showSearchView) {
                ArchiveSearchView(viewModel: .init())
            }
            .navigationTitle("")
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .orange)
    }
}
