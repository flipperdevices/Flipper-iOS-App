import Core
import SwiftUI

struct BaseInfoView: View {
    let onShare: () -> Void
    let onDelete: () -> Void
    let onOpenNFCEdit: () -> Void

    @Binding var current: ArchiveItem
    @Binding var isEditing: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
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

                VStack(alignment: .leading, spacing: 2) {
                    if current.isEditableNFC {
                        InfoButton(
                            image: "HexEditor",
                            title: "Edit Dump",
                            action: onOpenNFCEdit
                        )
                        .foregroundColor(.primary)
                    }
                    InfoButton(
                        image: "Share",
                        title: "Share",
                        action: onShare)
                    .foregroundColor(.primary)
                    InfoButton(
                        image: "Delete",
                        title: "Delete",
                        action: onDelete)
                    .foregroundColor(.sRed)
                }
                .padding(.top, 8)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }

            PrincipalToolbarItems {
                Title(
                    current.isNFC ? "Card Info" : "Key Info",
                    description: current.name.value
                )
            }
        }
    }
}

extension ArchiveItem {
    var isNFC: Bool {
        kind == .nfc
    }

    var isEditableNFC: Bool {
        guard isNFC, let typeProperty = properties.first(
            where: { $0.key == "Mifare Classic type" }
        ) else {
            return false
        }
        return ["MINI", "1K", "4K"].contains(typeProperty.value)
    }
}
