import Core
import SwiftUI

extension CardView {
    struct CardHeaderView: View {
        @Binding var item: ArchiveItem
        let kind: Kind
        let isEditing: Bool

        var isDeleted: Bool {
            item.status == .deleted
        }

        var body: some View {
            HStack(alignment: .top, spacing: 0) {
                FileTypeView(
                    item.kind,
                    isDeleted: isDeleted)
                Spacer()

                Button {
                    item.isFavorite.toggle()
                } label: {
                    Image(item.isFavorite ? "StarFilled" : "Star")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.sYellow)
                }
                .padding(8)
                .opacity(kind == .existing && !isEditing && !isDeleted ? 1 : 0)

                VStack(spacing: 2) {
                    item.status.image
                    Text(item.status.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                .padding([.top, .trailing], 6)
                .opacity(kind == .existing && !isEditing && !isDeleted ? 1 : 0)
            }
        }
    }
}

extension ArchiveItem.Status {
    var title: String {
        switch self {
        case .synchronized: return "Synced"
        case .synchronizing: return "Syncing..."
        default: return ""
        }
    }
}
