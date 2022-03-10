import Core
import SwiftUI
import Combine

struct ArchiveView: View {
    @StateObject var viewModel: ArchiveViewModel
    @State var showSearchView = false

    var body: some View {
        NavigationView {
            ScrollView {
                CategoryCard(
                    groups: viewModel.groups,
                    deleted: viewModel.deleted
                )
                .padding(14)

                ArchiveCompactList(name: "All", items: viewModel.items)
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
                        showSearchView = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showSearchView) {
                ArchiveSearchView()
            }
            .navigationTitle("")
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .orange)
    }
}
