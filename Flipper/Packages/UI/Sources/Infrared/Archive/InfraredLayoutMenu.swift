import Core
import SwiftUI

struct InfraredLayoutMenuButton: View {
    @EnvironmentObject var emulate: Emulate
    @Environment(\.popups) private var popups

    @Binding var item: ArchiveItem

    let onShare: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onHowTo: () -> Void

    var body: some View {
        EllipsisButton {
            popups.infrared.showOptions = true
        }
        .popup(isPresented: popups.infrared.showOptions) {
            HStack {
                Spacer()
                InfraredLayoutMenu(
                    isPresented: popups.infrared.showOptions,
                    item: $item,
                    onShare: onShare,
                    onDelete: onDelete,
                    onEdit: onEdit,
                    onHowTo: onHowTo
                )
                .environmentObject(emulate)
            }
            .padding(.horizontal, 14)
            .offset(y: 40)
        }
    }
}

struct InfraredLayoutMenu: View {
    @EnvironmentObject var emulate: Emulate

    @Binding var isPresented: Bool
    @Binding var item: ArchiveItem

    let onShare: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onHowTo: () -> Void

    var isEditable: Bool {
        !emulate.inProgress
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 0) {
                InfraredMenuItem(
                    title: item.isFavorite
                        ? "Added"
                        : "Add to Favorites",
                    image: item.isFavorite ? "StarFilled" : "Star",
                    imageColor: .sYellow
                ) {
                    isPresented = false
                    item.isFavorite.toggle()
                }

                Divider()
                    .padding(0)

                InfraredMenuItem(
                    title: "Rename",
                    image: "Edit"
                ) {
                    isPresented = false
                    onEdit()
                }

                Divider()
                    .padding(0)

                InfraredMenuItem(
                    title: "How to Use",
                    image: "HowTo"
                ) {
                    isPresented = false
                    onHowTo()
                }

                Divider()
                    .padding(0)

                InfraredMenuItem(
                    title: "Delete",
                    image: "Delete",
                    role: .destructive
                ) {
                    isPresented = false
                    onDelete()
                }
                .disabled(!isEditable)
            }
        }
        .frame(width: 220)
    }
}
