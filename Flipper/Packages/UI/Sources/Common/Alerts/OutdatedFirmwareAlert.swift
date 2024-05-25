import SwiftUI

struct OutdatedFirmwareAlert: View {
    @Environment(\.openURL) private var openURL
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            Image("OutdatedFirmware")
                .resizable()
                .frame(width: 82, height: 82)
                .padding(.top, 8)

            Text("Outdated Firmware Version")
                .font(.system(size: 14, weight: .bold))
                .padding(.top, 24)

            Text(
                "Firmware version on your Flipper is not supported. " +
                "Please update it via PC"
            )
            .font(.system(size: 14, weight: .medium))
            .multilineTextAlignment(.center)
            .foregroundColor(.black40)
            .padding(.top, 4)

            Button {
                openURL(.helpToInstallFirmware)
                isPresented = false
            } label: {
                Text("How to update Flipper")
                    .underline()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.a2)
            .padding(.top, 8)

            Button {
                isPresented = false
            } label: {
                Text("Got It")
                    .frame(height: 41)
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .background(Color.a2)
                    .cornerRadius(30)
            }
            .padding(.top, 23)
        }
        .padding(.top, 13)
    }
}
