import SwiftUI

struct UnsupportedDevice: View {
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Firmware Update")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }

                Image("Outdated")
                    .padding(.top, 9)

                Text("Outdated firmware version")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                Text("Firmware version on your Flipper is not supported. Please update it via PC.")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
                    .padding(.top, 4)

                Button {
                    UIApplication.shared.open(.helpToInstallFirmware)
                } label: {
                    Text("How to update Flipper")
                        .underline()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.a2)
                .padding(.top, 8)
            }
            .padding(12)
        }
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}
