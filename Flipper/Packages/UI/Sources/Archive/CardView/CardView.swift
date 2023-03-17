import Core
import SwiftUI

struct CardView: View {
    @Binding var item: ArchiveItem
    @Binding var isEditing: Bool
    let kind: Kind

    enum Kind {
        case existing
        case imported
        case deleted
    }

    @State private var focusedField: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardHeaderView(
                item: $item,
                kind: kind,
                isEditing: isEditing)

            CardNameView(
                item: $item,
                kind: kind,
                isEditing: $isEditing,
                focusedField: $focusedField
            )
            .padding(.top, 21)
            .padding(.horizontal, 12)

            Divider()
                .frame(height: 1)
                .background(Color.black12)
                .padding(.top, 18)

            CardDataView(
                item: $item,
                isEditing: isEditing,
                focusedField: $focusedField
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 18)
        }
        .background(Color.groupedBackground)
        .cornerRadius(16)
        .shadow(color: .shadow, radius: 16, x: 0, y: 4)
    }
}
