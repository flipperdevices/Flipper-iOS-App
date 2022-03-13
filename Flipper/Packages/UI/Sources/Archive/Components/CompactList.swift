import Core
import SwiftUI

struct CompactList: View {
    let name: String
    let items: [ArchiveItem]
    let onItemSelected: (ArchiveItem) -> Void

    let columns = [
        GridItem(.flexible(minimum: 0, maximum: .infinity)),
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("All")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }

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
}
