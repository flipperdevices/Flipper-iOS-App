import SwiftUI

struct AddKeyButton: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            addKey()
        } label: {
            AddKeyView {
                addKey()
            }
        }
    }

    func addKey() {
        #if os(iOS)
        openURL(.todayWidgetSettings)
        #endif
    }
}
