import Core
import SwiftUI

extension ArchiveView {
    struct FavoritesSection: View {
        @Environment(\.path) private var path

        let items: [ArchiveItem]

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

                CompactList(items: items) { item in
                    path.append(Destination.info(item))
                }
            }
        }
    }
}
