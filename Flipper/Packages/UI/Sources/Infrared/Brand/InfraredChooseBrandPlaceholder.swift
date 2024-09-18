import SwiftUI

extension InfraredView {
    struct ChooseBrandPlaceholder: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                AnimatedPlaceholder()
                    .cornerRadius(8)
                    .frame(height: 32)
                    .frame(maxWidth: .infinity)

                AnimatedPlaceholder()
                    .cornerRadius(8)
                    .frame(width: 28, height: 28)

                AnimatedPlaceholder()
                    .cornerRadius(8)
                    .frame(width: 160, height: 28)

                AnimatedPlaceholder()
                    .cornerRadius(8)
                    .frame(width: 160, height: 28)

                Spacer()
            }
            .padding(16)
        }
    }
}

#Preview {
    InfraredView.ChooseBrandPlaceholder()
}
