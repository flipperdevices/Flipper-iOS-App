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
        .onAppear {
            reportUnsupportedNFCVersion()
        }
    }

    func reportUnsupportedNFCVersion() {
        guard
            current.isNFC,
            current.isMifareClassicType,
            !current.isSupportedNFCVersion
        else { return }

        analytics.debug(info: .unknownNFCVersion(current.version ?? ""))
    }
}

private extension ArchiveItem {
    var isNFC: Bool {
        kind == .nfc
    }

    var version: String? {
        properties["Version"]
    }

    var isMifareClassicType: Bool {
        properties["Device type"] == "Mifare Classic"
    }

    var isEditableNFC: Bool {
        guard isNFC, let type = properties["Mifare Classic type"] else {
            return false
        }

        return ["MINI", "1K", "4K"].contains(type)
    }

    var isSupportedNFCVersion: Bool {
        guard isNFC, let version = version else {
            return false
        }

        return ["2", "3", "4"].contains(version)
    }
}
