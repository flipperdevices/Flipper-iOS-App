import Core
import SwiftUI

extension CardView {
    struct CardNameInfoView: View {
        @Binding var item: ArchiveItem
        let kind: Kind

        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Text(item.name.value)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)

                    Image(systemName: item.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.yellow)
                        .opacity(kind == .existing ? 1 : 0)
                }

                if item.note.isEmpty {
                    Text("Note is empty")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                        .italic()
                } else {
                    Text(item.note)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                        .lineLimit(1)
                }
            }
        }
    }
}
