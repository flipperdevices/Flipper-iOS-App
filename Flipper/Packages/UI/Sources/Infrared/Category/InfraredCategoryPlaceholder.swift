import Core
import SwiftUI

extension InfraredView {
    struct CategoryPlaceholder: View {
        var body: some View {
            AnimatedPlaceholder()
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .cornerRadius(16)
                .shadow(color: .shadow, radius: 16, x: 0, y: 4)
        }
    }
}
