import SwiftUI

struct InfraredMenuButton: View {
    let onShare: () -> Void
    let onDelete: () -> Void

    @State private var showMenu = false
    @State private var showHowToUse: Bool = false

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
                    onDelete: onDelete
                )
            }
            .padding(.horizontal, 14)
            .offset(y: 44)
        }
    }
}
