import Core
import SwiftUI
import OrderedCollections

struct CategoryCard: View {
    let groups: OrderedDictionary<ArchiveItem.FileType, [ArchiveItem]>
    let deleted: [ArchiveItem]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(groups.keys, id: \.self) { key in
                CategoryLink(
                    image: key.icon,
                    name: key.name,
                    count: groups[key]?.count ?? 0)
            }

            Divider()
                .padding(.top, 2)
                .padding(.bottom, 1)

            CategoryLink(
                image: nil,
                name: "Deleted",
                count: deleted.count)
        }
        .background(Color.groupedBackground)
        .cornerRadius(10)
        .shadow(color: .shadow, radius: 16, x: 0, y: 4)
    }
}

struct CategoryRow: View {
    let image: Image?
    let name: String
    let count: Int

    var body: some View {
        HStack(spacing: 0) {
            if let image = image {
                image
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.primary)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 8)
            }
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            Spacer()
            // swiftlint:disable empty_count
            Text(count == 0 ? "" : "\(count)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black30)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black30)
                .padding(.leading, 7)
        }
        .padding(.horizontal, 12)
        .frame(height: 44, alignment: .center)
    }
}

struct CategoryLink: View {
    let image: Image?
    let name: String
    let count: Int

    var body: some View {
        NavigationLink {
            CategoryView(name: name)
        } label: {
            CategoryRow(image: image, name: name, count: count)
        }
    }
}
