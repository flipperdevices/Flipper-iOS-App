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
                
                MessageText {
                    $0.attributedText = message
                    $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                    $0.textAlignment = .center
                    $0.textColor = UIColor(Color.black40)
                }
                .padding(.horizontal, 12)
                .fixedSize()
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

fileprivate struct MessageText: UIViewRepresentable {
    fileprivate var configuration = { (view: UILabel) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel {
        return UILabel()
    }
    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}
