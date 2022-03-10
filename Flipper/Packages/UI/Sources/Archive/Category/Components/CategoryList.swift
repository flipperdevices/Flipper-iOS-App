import Core
import SwiftUI

struct CategoryList: View {
    let items: [ArchiveItem]

    var body: some View {
        LazyVStack(spacing: 14) {
            ForEach(items) { item in
                CategoryItem(item: item)
            }
        }
    }
}
