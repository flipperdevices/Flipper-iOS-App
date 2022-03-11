import Core
import SwiftUI

struct CompactItem: View {
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
