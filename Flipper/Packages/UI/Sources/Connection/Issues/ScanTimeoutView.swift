import SwiftUI

struct ScanTimeoutView: View {
    var retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Image("NoDeviceFoundIssue")

            Text("Flipper Devices Not Found")
                .font(.system(size: 16, weight: .medium))

            Text(
                """
                Check Bluetooth connection
                on your Flipper and retry
                """
            )
            .multilineTextAlignment(.center)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.black40)

            Button {
                retry()
            } label: {
                Text("Retry")
                    .frame(height: 44)
                    .padding(.horizontal, 38)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .font(.system(size: 14, weight: .bold))
                    .cornerRadius(22)
            }
            .padding(.top, 12)

            Spacer()
            Spacer()
        }
    }
}
