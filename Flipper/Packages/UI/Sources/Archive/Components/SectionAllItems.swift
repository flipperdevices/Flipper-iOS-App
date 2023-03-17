import Core
import SwiftUI

extension ArchiveView {
    struct AllItemsSection: View {
        let items: [ArchiveItem]
        var onItemSelected: (ArchiveItem) -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("All")
                        .font(.system(size: 16, weight: .bold))
                }

                CompactList(items: items) { item in
                    onItemSelected(item)
                }
            }
        }
    }
}
