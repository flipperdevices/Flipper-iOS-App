import SwiftUI

extension DeviceUpdateView {
    struct StorageErrorView: View {
        var text: String {
            "Flipper’s internal flash storage is full or broken. " +
            "Free up space or try factory resetting to restore the " +
            "internal flash storage."
        }

        var body: some View {
            VStack(spacing: 0) {
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.top, 3)

                Button {
                    UIApplication.shared.open(.helpToFactoryReset)
                } label: {
                    Text("How to do Factory Reset")
                        .font(.system(size: 14, weight: .medium))
                        .underline()
                }
                .padding(.top, 18)
            }
            .padding(.top, 38)
            .padding(.horizontal, 24)
        }
    }
}
