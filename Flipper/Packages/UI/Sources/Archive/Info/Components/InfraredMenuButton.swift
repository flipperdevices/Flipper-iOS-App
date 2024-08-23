import Core
import SwiftUI

struct InfraredMenuButton: View {
    @Environment(\.popups) private var popups

    let onShare: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void

    @State private var showHowToUse: Bool = false

    // FIXME: Rewrite by use more flexible env object
    @EnvironmentObject var emulate: Emulate

    var body: some View {
        EllipsisButton {
            popups.infrared.showOptions = true
        }
        .alert(isPresented: $showHowToUse) {
            InfraredHowToUseDialog(isPresented: $showHowToUse)
        }
        .popup(isPresented: popups.infrared.showOptions) {
            HStack {
                Spacer()
                InfraredMenu(
                    isPresented: popups.infrared.showOptions,
                    onShare: onShare,
                    onHowTo: { showHowToUse = true },
                    onDelete: onDelete,
                    onEdit: onEdit
                )
                .environmentObject(emulate)
            }
            .padding(.horizontal, 14)
            .offset(y: 44)
        }
    }
}
