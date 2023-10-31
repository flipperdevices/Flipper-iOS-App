import SwiftUI

struct UpdateFailedAlert: View {
    @Binding var isPresented: Bool

    let firmwareVersion: String

    var commonMessagePart =
        " wasn’t installed on your Flipper." +
        " Try to install it again"

    var message: String {
        firmwareVersion + commonMessagePart
    }

    @available(iOS 15, *)
    var messageAttributed: AttributedString {
        var version = AttributedString(firmwareVersion)
        version.foregroundColor = .primary
        var message = AttributedString(commonMessagePart)
        message.foregroundColor = .init(uiColor: .init(.black40))
        return version + message
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("UpdateFailed")
                .padding(.top, 17)

            Text("Update Failed")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.sRed)
                .padding(.top, 24)

            messageView
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

    var messageView: some View {
        if #available(iOS 15, *) {
            return Text(messageAttributed)
        } else {
            return Text(message)
        }
    }
}
