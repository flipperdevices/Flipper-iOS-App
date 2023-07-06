import SwiftUI

struct MobileUpdateAlert: View {
    @Binding var isPresented: Bool

    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(spacing: 0) {
            Image("OutdatedMobile")
                .resizable()
                .frame(width: 120, height: 72)
                .padding(.top, 8)

            Text("Flipper App Update")
                .font(.system(size: 14, weight: .bold))
                .padding(.top, 24)

            Text("New version is available to install")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
                .padding(.top, 4)

            Button {
                openURL(.appStore)
                isPresented = false
            } label: {
                Text("Go to App Store")
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
