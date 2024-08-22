import SwiftUI

extension InfraredView {
    struct InfraredChooseBrandPlaceholder: View {
        var body: some View {
            AnimatedPlaceholder()
                .cornerRadius(8)
                .frame(height: 25)
                .frame(maxWidth: .infinity)
                .shadow(color: .shadow, radius: 16, x: 0, y: 4)
        }
    }
}
