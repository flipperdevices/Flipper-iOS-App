import SwiftUI
import AttributedText

struct UpdateFailedAlert: View {
    @Binding var isPresented: Bool

    let firmwareVersion: String

    var message: NSAttributedString {
        let version = NSMutableAttributedString(string: firmwareVersion)
        version.addAttributes(
            [.foregroundColor: Color.primary],
            range: NSRange(location: 0, length: version.length)
        )
        let message = NSMutableAttributedString(
            string: " wasn’t installed on your Flipper." +
            " Try to install it again")

        message.addAttributes(
            [.foregroundColor: Color.black40],
            range: NSRange(location: 0, length: message.length)
        )

        let result = NSMutableAttributedString()
        result.append(version)
        result.append(message)
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("UpdateFailed")
                .padding(.top, 17)

            Text("Update Failed")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.sRed)
                .padding(.top, 24)

            AttributedText(message)
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
