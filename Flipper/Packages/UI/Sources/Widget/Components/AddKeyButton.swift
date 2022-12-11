import SwiftUI

struct AddKeyButton: View {
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
        UIApplication.shared.open(.widgetSettings)
        #endif
    }
}
