import SwiftUI

struct ShareButton: View {
    var action: () -> Void

    var body: some View {
        NavBarButton(action: action) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 18, weight: .medium))
        }
    }
}
