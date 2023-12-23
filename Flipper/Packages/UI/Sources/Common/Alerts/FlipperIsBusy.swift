import SwiftUI

struct FlipperIsBusyAlert: View {
    @Binding var isPresented: Bool
    let goToRemote: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image("FlipperBusy")
                .padding(.top, 17)

            VStack(spacing: 4) {
                Text("Flipper is Busy")
                    .font(.system(size: 14, weight: .bold))

                Text("Exit the current app on Flipper to use this feature")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
            }
            .padding(.horizontal, 12)

            Button {
                isPresented = false
                goToRemote()
            } label: {
                Text("Go to Remote Control")
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
