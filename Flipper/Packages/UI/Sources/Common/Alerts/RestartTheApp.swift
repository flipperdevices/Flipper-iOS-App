import SwiftUI

struct RestartTheAppAlert: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("Restart the app")
                    .font(.system(size: 14, weight: .bold))

                Text("You need to restart the app to apply changes")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
                    .padding(.horizontal, 12)
            }

            Button {
                exit(0)
            } label: {
                Text("Exit")
                    .frame(height: 41)
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(30)
            }
        }
        .padding(.top, 13)
    }
}
