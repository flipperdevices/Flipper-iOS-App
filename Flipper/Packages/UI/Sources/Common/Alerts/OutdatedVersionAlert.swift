import SwiftUI

struct OutdatedVersionAlert: View {
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

            Text("Update Flipper firmware to use this feature")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
                .padding(.top, 4)

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
            .padding(.top, 24)
        }
        .padding(.top, 13)
    }
}
