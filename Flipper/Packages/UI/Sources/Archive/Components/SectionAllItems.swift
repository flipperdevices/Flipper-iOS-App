import Core
import SwiftUI

extension ArchiveView {
    struct AllItemsSection: View {
        @Environment(\.path) private var path

        let items: [ArchiveItem]

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("All")
                        .font(.system(size: 16, weight: .bold))
                }

                CompactList(items: items) { item in
                    path.append(Destination.info(item))
                }
            }
        }
    }
}
