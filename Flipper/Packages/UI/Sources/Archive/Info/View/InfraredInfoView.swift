import Core
import SwiftUI

struct InfraredInfoView: View {
    let onShare: () -> Void
    let onDelete: () -> Void

    @Binding var current: ArchiveItem
    @Binding var isEditing: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            InfraredSheetHeader(
                title: "Key Info",
                description: current.name.value,
                onCancel: { dismiss() },
                onShare: onShare,
                onDelete: onDelete
            )
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    CardView(
                        item: $current,
                        isEditing: $isEditing,
                        kind: .existing
                    )
                    .padding(.top, 6)
                    .padding(.horizontal, 24)

                    EmulateView(item: current)

                    Spacer()
                }
            }
        }
    }
}
