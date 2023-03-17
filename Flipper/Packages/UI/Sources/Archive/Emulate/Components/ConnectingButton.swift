import SwiftUI

struct ConnectingButton: View {
    var body: some View {
        AnimatedPlaceholder()
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
