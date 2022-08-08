import SwiftUI

struct UpdateFailedAlert: View {
    @Binding var isPresented: Bool

    var firmwareVersion: String
    var firmwareVersionColor: Color

    var message: AttributedString {
        var version = AttributedString(firmwareVersion)
        version.foregroundColor = .init(uiColor: .init(firmwareVersionColor))
        var message = AttributedString(
            " wasn’t installed on your Flipper." +
            " Try to install it again")
        message.foregroundColor = .init(uiColor: .init(.black40))
        return version + message
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("UpdateFailed")
                .padding(.top, 17)

            Text("Update Failed")
                .font(.system(size: 14, weight: .bold))
                .padding(.top, 24)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
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
