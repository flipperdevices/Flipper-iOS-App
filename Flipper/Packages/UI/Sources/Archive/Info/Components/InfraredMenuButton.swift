import Core
import SwiftUI

struct InfraredMenuButton: View {
    let onShare: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void

    @State private var showMenu = false
    @State private var showHowToUse: Bool = false

    // FIXME: Rewrite by use more flexible env object
    @EnvironmentObject var emulate: Emulate

    var body: some View {
        EllipsisButton {
            showMenu = true
        }
        .alert(isPresented: $showHowToUse) {
            InfraredHowToUseDialog(isPresented: $showHowToUse)
        }
        .popup(isPresented: $showMenu) {
            HStack {
                Spacer()
                InfraredMenu(
                    isPresented: $showMenu,
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
