import SwiftUI

struct CloseButton: View {
    var action: () -> Void

    var body: some View {
        NavBarButton(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .medium))
        }
    }
}
