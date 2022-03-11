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

            RoundedButton("Retry") {
                retry()
            }
            .padding(.top, 12)

            Spacer()
            Spacer()
        }
    }
}
