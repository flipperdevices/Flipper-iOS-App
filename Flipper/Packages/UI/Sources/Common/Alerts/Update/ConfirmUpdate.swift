import Core
import SwiftUI

struct ConfirmUpdateAlert: View {
    @Binding var isPresented: Bool
    let installedVersion: Update.Version
    let availableVersion: Update.Version
    var onAction: () -> Void

    var isSameChannel: Bool {
        installedVersion.channel == availableVersion.channel
    }

    var action: String {
        isSameChannel ? "Update" : "Install"
    }

    var message: AttributedString {
        var message = AttributedString(
            "New firmware \(availableVersion) will be installed")
        if let range = message.range(of: "\(availableVersion)") {
            message[range].foregroundColor = availableVersion.color
        }
        return message
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("\(action) Firmware?")
                    .font(.system(size: 14, weight: .bold))

                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
                    .padding(.horizontal, 12)
            }
            .padding(.top, 25)

            // TODO: move to view builder

            VStack(spacing: 14) {
                Divider()

                Button {
                    onAction()
                    isPresented = false
                } label: {
                    Text(action)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.a2)
                }

                Divider()

                Button {
                    isPresented = false
                } label: {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
        }
    }
}
