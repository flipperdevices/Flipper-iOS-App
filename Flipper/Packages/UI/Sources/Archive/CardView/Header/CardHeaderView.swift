import Core
import SwiftUI

extension CardView {
    struct CardHeaderView: View {
        let item: ArchiveItem
        let kind: Kind
        let isEditing: Bool

        var body: some View {
            HStack(alignment: .top, spacing: 0) {
                FileTypeView(item.fileType)
                Spacer()
                VStack(spacing: 2) {
                    Image("synced")
                    Text("Synced")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                .padding([.top, .trailing], 6)
                .opacity(kind == .existing && !isEditing ? 1 : 0)
            }
        }
    }
}
