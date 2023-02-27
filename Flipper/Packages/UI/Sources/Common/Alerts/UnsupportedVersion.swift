import SwiftUI

struct UnsupportedVersionAlert: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            Image("Outdated")
                .resizable()
                .frame(width: 82, height: 82)
                .padding(.top, 8)

            Text("Outdated firmware version")
                .font(.system(size: 14, weight: .bold))
                .padding(.top, 24)

            Text(
                "Firmware version on your Flipper is not supported. " +
                "Please update it via PC"
            )
            .font(.system(size: 14, weight: .medium))
            .multilineTextAlignment(.center)
            .foregroundColor(.black40)
            .padding(.horizontal, 12)
            .padding(.top, 4)

            Button {
                isPresented = false
            } label: {
                Text("Ok")
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
