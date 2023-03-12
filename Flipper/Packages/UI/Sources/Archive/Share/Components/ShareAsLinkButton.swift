import SwiftUI

extension ShareView {
    struct ShareAsLinkButton: View {
        let isTempLink: Bool
        var action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                VStack(spacing: 12) {
                    Image("ShareAsLink")
                    VStack(spacing: 2) {
                        Text("via Secure Link")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.a1)
                        Text("Expires in 30 days")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.black30)
                            .opacity(isTempLink ? 1 : 0)
                    }
                }
            }
        }
    }
}
