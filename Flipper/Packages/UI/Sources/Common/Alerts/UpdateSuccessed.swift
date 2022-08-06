import SwiftUI

struct UpdateSuccessedAlert: View {
    @Environment(\.dismiss) var dismiss

    var firmwareVersion: String
    var firmwareVersionColor: Color

    var message: AttributedString {
        var version = AttributedString(firmwareVersion)
        version.foregroundColor = .init(uiColor: .init(firmwareVersionColor))
        var message = AttributedString(" was installed on your Flipper")
        message.foregroundColor = .init(uiColor: .init(.black40))
        return version + message
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("UpdateSuccessed")
                .renderingMode(.template)
                .foregroundColor(.primary)
                .padding(.top, 17)

            Text("Update Successful")
                .font(.system(size: 14, weight: .bold))
                .padding(.top, 24)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.top, 4)

            Button {
                withoutAnimation {
                    dismiss()
                }
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
