import SwiftUI

struct SearchButton: View {
    var action: () -> Void

    var body: some View {
        NavBarButton(action: action) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
        }
    }
}
