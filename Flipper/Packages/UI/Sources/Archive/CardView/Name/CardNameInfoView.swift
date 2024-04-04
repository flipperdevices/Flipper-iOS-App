import Core
import SwiftUI

extension CardView {
    struct CardNameInfoView: View {
        @Environment(\.isEditable) private var isEditable

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

                    CardNameEditButton {
                        withAnimation {
                            isEditing = true
                        }
                    }
                    .opacity(kind != .deleted ? 1 : 0)
                    .disabled(!isEditable)
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

    struct CardNameEditButton: View {
        @Environment(\.isEnabled) private var isEnabled

        let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        var body: some View {
            Button(action: action) {
                SmallImage("Edit")
                    .foregroundColor(isEnabled ? .primary : .emulateDisabled)
            }
        }
    }
}
