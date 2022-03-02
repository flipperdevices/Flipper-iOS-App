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

            Button {
                Application.openSettings()
            } label: {
                Text("Go to Settings")
                    .frame(height: 44)
                    .padding(.horizontal, 38)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .font(.system(size: 14, weight: .bold))
                    .cornerRadius(22)
            }
            .padding(.top, 12)

            Spacer()
        }
    }
}
