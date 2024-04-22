import SwiftUI

struct EllipsisButton: View {
    var action: () -> Void

    var body: some View {
        NavBarButton(action: action) {
            Image(systemName: "ellipsis")
                .font(.system(size: 18, weight: .medium))
        }
    }
}
