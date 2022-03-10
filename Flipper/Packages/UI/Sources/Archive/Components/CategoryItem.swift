import Core
import SwiftUI

struct CategoryItem: View {
    let item: ArchiveItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                FileTypeView(item.fileType)
                Text(item.type)
                    .padding(.top, 14)
                    .padding(.leading, 14)
                    .foregroundColor(.black12)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Image("synced")
                    .padding([.top, .trailing], 8)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name.value)
                    .lineLimit(1)
                    .font(.system(size: 14, weight: .medium))

                if !item.description.isEmpty {
                    Text(item.description)
                        .lineLimit(1)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black30)
                }
            }
            .padding(.horizontal, 8)
            .frame(maxHeight: .infinity)
        }
        .frame(height: 93)
        .background(Color.groupedBackground)
        .cornerRadius(10)
        .compositingGroup()
        .shadow(color: .shadow, radius: 16, x: 0, y: 4)
    }
}

fileprivate extension ArchiveItem {
    var type: String { self["Filetype"] ?? "" }
}
