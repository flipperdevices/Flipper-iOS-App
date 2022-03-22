import SwiftUI

struct UnsupportedDeviceSection: View {
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Firmware Update")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }

                Image("Update")
                    .padding(.top, 18)

                Text("Update your Flipper using qFlipper")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.top, 12)

                Text("Our app doesn’t support this firmware version")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black40)
                    .padding(.top, 8)

                Button {
                    UIApplication.shared.open(.helpToInstallFirmware)
                } label: {
                    Text("How to update Flipper")
                        .underline()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black60)
                .padding(.top, 12)
            }
            .padding(12)
        }
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}
