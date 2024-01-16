import Core
import SwiftUI

struct EditInfoView: View {
    let saveChanges: () -> Void
    let undoChanges: () -> Void
    @Binding var current: ArchiveItem
    @Binding var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SheetEditHeader(
                title: "Editing",
                description: current.name.value,
                onSave: saveChanges,
                onCancel: undoChanges
            )

            CardView(
                item: $current,
                isEditing: $isEditing,
                kind: .existing
            )
            .padding(.top, 6)
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}
