import Core
import SwiftUI
import AttributedText

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

    var message: NSAttributedString {
        let message = NSMutableAttributedString(
            string: "New firmware \(availableVersion) will be installed")
        
        if let range = message.string.range(of: "\(availableVersion)") {
            message.addAttribute(.foregroundColor, value: availableVersion.color, range: NSRange(range, in: message.string))
        }
        
        return message
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("\(action) Firmware?")
                    .font(.system(size: 14, weight: .bold))

                AttributedText(message)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
                    .padding(.horizontal, 12)
            }
            .padding(.top, 25)

            AlertButtons(
                isPresented: $isPresented,
                text: action,
                cancel: "Cancel"
            ) {
                onAction()
            }
        }
    }
}
