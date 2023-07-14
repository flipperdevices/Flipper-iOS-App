import SwiftUI
import AttributedText

struct AppsOutdatedFlipperAlert: View {
    @Binding var isPresented: Bool

    @AppStorage(.selectedTabKey) var selectedTab: TabView.Tab = .device

    var message: NSAttributedString {
        let string = NSMutableAttributedString(
            string: "This app requires the latest Flipper firmware version " +
            "from Release channel"
        )
        
        if let range = string.string.range(of: "Release") {
            string.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: NSRange(range, in: string.string))
        }
        
        return string
    }

    var body: some View {
        VStack(spacing: 24) {
            Image("AppAlertUnsupported")
                .padding(.top, 17)

            VStack(spacing: 4) {
                Text("To install, update firmware from Release Channel")
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.center)

                AttributedText(message)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
            }
            .padding(.horizontal, 12)

            Button {
                selectedTab = .device
                isPresented = false
            } label: {
                Text("Go to Device Screen")
                    .frame(height: 41)
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .background(Color.a2)
                    .cornerRadius(30)
            }
        }
    }
}
