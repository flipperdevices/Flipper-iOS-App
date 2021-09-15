import Core
import SwiftUI

struct ArchiveListView: View {
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color { colorScheme == .light ? .white : .black }

    var itemSelected: (ArchiveItem) -> Void

    init(itemSelected: @escaping (ArchiveItem) -> Void ) {
        self.itemSelected = itemSelected
    }

    var body: some View {
        ScrollView {
            Spacer(minLength: 12)
            ForEach(demo) { item in
                Button {
                    itemSelected(item)
                } label: {
                    ArchiveListItemView(item: item)
                        .foregroundColor(.primary)
                        .background(backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .padding(.leading, 16)
        .padding(.trailing, 15)
        .background(Color.gray.opacity(0.1))
    }
}

struct ArchiveListItemView: View {
    let item: ArchiveItem

    var body: some View {
        HStack(spacing: 15) {
            item.icon
                .resizable()
                .frame(width: 23, height: 23)
                .scaledToFit()
                .padding(.horizontal, 17)
                .padding(.vertical, 22)
                .background(item.color)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .fontWeight(.medium)

                Text(item.origin)
                    .fontWeight(.thin)
            }

            Spacer()

            VStack {
                Spacer()
                Image(systemName: "checkmark")
                    .font(.system(size: 14))
                    .padding(.trailing, 15)
                    .foregroundColor(.secondary)
                    .opacity([true, false].randomElement() ?? false ? 1 : 0)
                Spacer()
            }
        }
    }
}
