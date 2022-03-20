import SwiftUI

struct BluetoothAccessView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Image("BluetoothAccessIssue")

            Text("Allow Bluetooth Access")
                .font(.system(size: 16, weight: .medium))

            Text(
                """
                We need Bluetooth access to
                confirm the connection between
                your phone and Flipper Device
                """
            )
            .multilineTextAlignment(.center)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.black40)

            RoundedButton("Go to Settings") {
                Application.openSettings()
            }
            .padding(.top, 12)

            Spacer()
        }
    }
}
