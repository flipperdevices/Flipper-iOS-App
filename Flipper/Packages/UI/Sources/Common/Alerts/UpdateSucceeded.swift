import SwiftUI

struct UpdateSucceededAlert: View {
    @Binding var isPresented: Bool

    let firmwareVersion: String

    var message: AttributedString {
        var version = AttributedString(firmwareVersion)
        version.foregroundColor = .primary
        var message = AttributedString(" was installed on your Flipper")
        message.foregroundColor = .init(.black40)
        return version + message
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("FlipperSuccess")
                .renderingMode(.template)
                .foregroundColor(.blackBlack20)
                .padding(.top, 17)

            Text("Update Successful")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.sGreenUpdate)
                .padding(.top, 24)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
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
            .padding(.top, 24)
        }
    }
}
