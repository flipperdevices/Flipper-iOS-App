import Core
import SwiftUI

struct CategoryList: View {
    let items: [ArchiveItem]
    let onItemSelected: (ArchiveItem) -> Void

    var body: some View {
        LazyVStack(spacing: 14) {
            ForEach(items) { item in
                Button {
                    onItemSelected(item)
                } label: {
                    CategoryItem(item: item)
                }
                .foregroundColor(.primary)
            }
        }
    }
}
