import SwiftUI

struct BackButton: View {
    var action: () -> Void

    var body: some View {
        NavBarButton(action: action) {
            Image(systemName: "chevron.backward")
                .font(.system(size: 18, weight: .medium))
        }
    }
}

#Preview {
    BackButton(action: {})
}
