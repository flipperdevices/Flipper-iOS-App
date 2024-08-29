import SwiftUI

struct InfraredHowToUseRemoteDialog: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 24) {
            Image("InfraredHowTo")
                .padding(.top, 17)

            VStack(spacing: 4) {
                Text("How to Use")
                    .font(.system(size: 14, weight: .bold))

                Text("Point Flipper Zero at the device. Tap or hold " +
                     "the button from your phone to send the signal remotely")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
            }
            .padding(.horizontal, 12)

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
        }
    }
}
