import Core
import SwiftUI

struct ArchiveView: View {
    @ObservedObject var viewModel: ArchiveViewModel

    init(viewModel: ArchiveViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .center) {
            List(viewModel.items) { item in
                ArchiveListItemView(item: item)
            }

            Spacer()

            RoundedButton("Read NFC Tag") {
                viewModel.readNFCTag()
            }
            .padding(.bottom, 30)
        }
    }
}

struct ArchiveListItemView: View {
    let item: ArchiveItem

    var body: some View {
        HStack(spacing: 15) {
            item.icon
                .frame(width: 23, height: 23)
                .scaledToFit()
            VStack(spacing: 10) {
                HStack {
                    Text(item.name)
                        .bold()
                    if item.isFavorite {
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text(item.description)
                    Spacer()
                    Text(item.origin)
                    Image(systemName: "checkmark")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView(viewModel: .init())
    }
}
