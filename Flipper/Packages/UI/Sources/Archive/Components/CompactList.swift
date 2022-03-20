import Core
import SwiftUI

struct CompactList: View {
    let items: [ArchiveItem]
    let onItemSelected: (ArchiveItem) -> Void

    let columns = [
        GridItem(.flexible(minimum: 0, maximum: .infinity)),
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(items) { item in
                Button {
                    onItemSelected(item)
                } label: {
                    CompactItem(item: item)
                }
                .foregroundColor(.primary)
            }
        }
    }
}
