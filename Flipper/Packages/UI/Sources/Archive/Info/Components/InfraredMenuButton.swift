import SwiftUI

struct InfraredMenuButton: View {
    let onShare: () -> Void
    let onDelete: () -> Void

    @State private var showInfraredOption = false
    @State private var showHowToUse: Bool = false
    @State private var menuOffset = 0.0

    var body: some View {
        NavBarButton {
            showInfraredOption = true
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 18, weight: .medium))
        }
        .background(GeometryReader {
            let frame = $0.frame(in: .global)
            Color.clear.preference(
                key: MenuOffsetKey.self,
                value: frame.origin.y)
        })
        .onPreferenceChange(MenuOffsetKey.self) {
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
            .offset(y: menuOffset + 28)
        }
    }
}

private struct MenuOffsetKey: PreferenceKey {
    typealias Value = Double

    static var defaultValue = Double.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
