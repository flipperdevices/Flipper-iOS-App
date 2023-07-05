import Core
import SwiftUI

struct PauseSyncAlert: View {
    @Binding var isPresented: Bool
    let installedVersion: Update.Version
    let availableVersion: Update.Version
    var onAction: () -> Void

    var isSameChannel: Bool {
        installedVersion.channel == availableVersion.channel
    }

    var messageAction: String {
        isSameChannel ? "update to" : "install"
    }

    var buttonAction: String {
        isSameChannel ? "Update" : "Install"
    }

    var message: AttributedString {
        var message = AttributedString(
            "Cannot \(messageAction) to \(availableVersion) during " +
            "synchronization. Wait for sync to finish or pause it.")
        if let range = message.range(of: "\(availableVersion)") {
            message[range].foregroundColor = availableVersion.color
        }
        return message
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("Pause Synchronization?")
                    .font(.system(size: 14, weight: .bold))

                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
                    .padding(.horizontal, 12)
            }
            .padding(.top, 25)

            AlertButtons(
                isPresented: $isPresented,
                text: "Pause & \(buttonAction)",
                cancel: "Cancel"
            ) {
                onAction()
            }
        }
    }
}
