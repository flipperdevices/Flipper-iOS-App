import SwiftUI

struct ScreenshotButton: View {
    var action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button {
                action()
            } label: {
                Image("RemoteScreenshot")
            }
            Text("Screenshot")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.a1)
        }
    }
}
