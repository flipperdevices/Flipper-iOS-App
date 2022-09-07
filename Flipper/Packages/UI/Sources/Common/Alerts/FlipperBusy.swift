import SwiftUI

struct FlipperBusyAlert: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            Image("FlipperBusy")
                .padding(.top, 17)

            Text("Flipper is Busy")
                .font(.system(size: 14, weight: .bold))
                .padding(.top, 25)

            Text("Exit the current app on Flipper to use this feature")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
                .padding(.horizontal, 12)
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
    }
}
