import SwiftUI

struct InfraredMenuButton: View {
    let onShare: () -> Void
    let onDelete: () -> Void

    @State private var showInfraredOption = false
    @State private var showHowToUse: Bool = false
    @State private var menuOffset = 0.0

    var body: some View {
        EllipsisButton {
            showInfraredOption = true
        }
        .background(GeometryReader {
            Color.clear.preference(
                key: OffsetKey.self,
                value: $0.frame(in: .global).origin.y)
        })
        .onPreferenceChange(OffsetKey.self) {
            menuOffset = $0
        }
        .alert(isPresented: $showHowToUse) {
            InfraredHowToUseDialog(isPresented: $showHowToUse)
        }
        .popup(isPresented: $showInfraredOption) {
            HStack {
                Spacer()
                InfraredMenu(
                    isPresented: $showInfraredOption,
                    onShare: onShare,
                    onHowTo: { showHowToUse = true },
                    onDelete: onDelete
                )
            }
            .padding(.horizontal, 14)
            .offset(y: menuOffset + platformOffset)
        }
    }
}
