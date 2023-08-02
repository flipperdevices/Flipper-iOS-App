import SwiftUI

extension DeviceUpdateView {
    struct StorageErrorView: View {
        @Environment(\.openURL) private var openURL

        var text: String {
            "Flipper’s internal flash storage is full or broken. " +
            "Free up space or try factory resetting to restore the " +
            "internal flash storage."
        }

        var body: some View {
            VStack(spacing: 18) {
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)

                Button {
                    openURL(.helpToFactoryReset)
                } label: {
                    Text("How to do Factory Reset")
                        .font(.system(size: 14, weight: .medium))
                        .underline()
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
