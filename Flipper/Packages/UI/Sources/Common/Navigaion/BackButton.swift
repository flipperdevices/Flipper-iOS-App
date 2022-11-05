import SwiftUI

struct BackButton: View {
    var action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        NavBarButton(action: action) {
            Image(systemName: "chevron.backward")
                .font(.system(size: 18, weight: .medium))
        }
    }
}
