import SwiftUI

struct SaveButton: View {
    var action: () -> Void

    var body: some View {
        NavBarButton(action: action) {
            Text("Save")
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 8)
        }
    }
}
