import Core
import SwiftUI

struct ArchiveHeaderView: View {
    @StateObject var viewModel: ArchiveViewModel

    var body: some View {
        HeaderView(
            title: viewModel.device?.name ?? .noDevice,
            status: .init(viewModel.device?.state),
            leftView: { leftView },
            rightView: { rightView })
    }

    @ViewBuilder var leftView: some View {
        if viewModel.isSelectItemsMode {
            Button {
                withAnimation {
                    viewModel.isSelectItemsMode = false
                }
            } label: {
                Text("Done")
                    .fontWeight(.medium)
                    .padding(.leading, UIDevice.isFaceIDAvailable ? 15.5 : 14)
            }
        } else {
            Menu {
                Button {
                    viewModel.toggleSelectItems()
                } label: {
                    Text("Choose items")
                    Image(systemName: "checkmark.circle")
                }
                Menu {
                    Button("Creation Date") {
                        viewModel.sortOption = .creationDate
                    }
                    Button("Title") {
                        viewModel.sortOption = .title
                    }
                    Divider()
                        .frame(height: 10)
                    Button("Older First") {
                        viewModel.sortOption = .oldestFirst
                    }
                    Button("Newest First") {
                        viewModel.sortOption = .newestFirst
                    }
                } label: {
                    Text("Sort items")
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .headerImageStyle()
            }
        }
    }

    @ViewBuilder var rightView: some View {
        Button {
            viewModel.readNFCTag()
        } label: {
            Image(systemName: "plus.circle")
                .headerImageStyle()
        }
        .opacity(viewModel.isSelectItemsMode ? 0 : 1)
    }
}
