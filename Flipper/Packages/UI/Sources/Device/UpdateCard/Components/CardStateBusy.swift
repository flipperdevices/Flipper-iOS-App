import SwiftUI

extension DeviceUpdateCard {
    struct CardStateBusy: View {
        var body: some View {
            HStack {
                Text("Update Channel")
                    .foregroundColor(.black30)

                Spacer()

                AnimatedPlaceholder()
                    .frame(width: 90, height: 17)
            }
            .font(.system(size: 14))
            .padding(.horizontal, 12)
            .padding(.top, 18)
            .padding(.bottom, 12)

            Divider()

            AnimatedPlaceholder()
                .frame(height: 46)
                .padding(12)
        }
    }
}
