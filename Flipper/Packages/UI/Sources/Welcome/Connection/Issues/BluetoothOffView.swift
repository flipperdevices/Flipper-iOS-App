import SwiftUI

struct BluetoothOffView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Image("BluetoothOffIssue")

            Text("Turn On Bluetooth")
                .font(.system(size: 16, weight: .medium))

            Text("Bluetooth on your phone is turned off")
                .multilineTextAlignment(.center)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black40)

            Button {
                Application.openSystemSettings()
            } label: {
                Text("Go to Settings")
                    .roundedButtonStyle()
            }
            .padding(.top, 12)

            Spacer()
        }
    }
}
