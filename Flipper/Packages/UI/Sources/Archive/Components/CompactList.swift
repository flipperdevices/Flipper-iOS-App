import Core
import SwiftUI

struct CompactList: View {
    let name: String
    let items: [ArchiveItem]

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
                    ArchiveCompactItem(item: item)
                }
            }
        }
    }
}

struct ArchiveCompactItem: View {
    let item: ArchiveItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                FileTypeView(item.fileType)
                Spacer()
                Image("synced")
                    .padding([.top, .trailing], 8)
            }

            Spacer()
            Text(item.name.value)
                .lineLimit(1)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 8)
            Spacer()
        }
        .frame(height: 81)
        .background(Color.groupedBackground)
        .cornerRadius(10)
        .compositingGroup()
        .shadow(color: .shadow, radius: 16, x: 0, y: 4)
    }
}
