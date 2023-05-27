import SwiftUI

struct BluetoothAccessView: View {
    @Environment(\.openURL) private var openURL

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
                openURL(.settings)
            } label: {
                Text("Go to Settings")
                    .roundedButtonStyle()
            }
            .padding(.top, 12)

            Spacer()
        }
    }
}
