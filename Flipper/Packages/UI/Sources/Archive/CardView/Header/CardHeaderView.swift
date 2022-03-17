import Core
import SwiftUI

extension CardView {
    struct CardHeaderView: View {
        let item: ArchiveItem
        let kind: Kind
        let isEditing: Bool

        var isDeleted: Bool {
            item.status == .deleted
        }

        var body: some View {
            HStack(alignment: .top, spacing: 0) {
                FileTypeView(
                    item.fileType,
                    isDeleted: isDeleted)
                Spacer()
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
