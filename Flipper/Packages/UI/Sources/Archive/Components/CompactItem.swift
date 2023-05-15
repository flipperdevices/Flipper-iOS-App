import Core
import SwiftUI

struct CompactItem: View {
    let item: ArchiveItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                FileTypeView(item.kind)
                Spacer()
                item.status.image
                    .padding([.top, .trailing], 8)
            }

            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Text(item.name.value)
                    .lineLimit(1)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 8)
                if item.subdirectories.count > 0 {
                    Text(item.subdirectories.joined(separator: "/")+"/")
                        .foregroundColor(.black60)
                        .lineLimit(1)
                        .font(.system(size: 10, weight: .regular))
                        .padding(.horizontal, 8)
                }
            }
            Spacer()
        }
        .frame(height: 84)
        .background(Color.groupedBackground)
        .cornerRadius(10)
        .compositingGroup()
        .shadow(color: .shadow, radius: 16, x: 0, y: 4)
    }
}
