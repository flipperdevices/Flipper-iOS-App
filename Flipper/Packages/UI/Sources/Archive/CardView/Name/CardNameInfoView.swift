import Core
import SwiftUI

extension CardView {
    struct CardNameInfoView: View {
        @Binding var item: ArchiveItem
        let kind: Kind
        @Binding var isEditing: Bool

        var isFavorite: Bool { item.isFavorite }
        var isDeleted: Bool { item.status == .deleted }

        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Text(item.name.value)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)

                    Button {
                        withAnimation {
                            isEditing = true
                        }
                    } label: {
                        Image("Edit")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.primary)
                            .opacity(kind == .existing ? 1 : 0)
                    }
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
                        .lineLimit(3)
                }
            }
        }
    }
}
