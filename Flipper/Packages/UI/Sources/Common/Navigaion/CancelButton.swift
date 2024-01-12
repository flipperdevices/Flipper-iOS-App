import SwiftUI

struct CancelButton: View {
    var action: () -> Void

    var body: some View {
        NavBarButton(action: action) {
            Text("Cancel")
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 8)
        }
    }
}

struct CancelSearchButton: View {
    var action: () -> Void

    var body: some View {
        NavBarButton(action: action) {
            Text("Cancel")
                .font(.system(size: 17))
        }
    }
}
