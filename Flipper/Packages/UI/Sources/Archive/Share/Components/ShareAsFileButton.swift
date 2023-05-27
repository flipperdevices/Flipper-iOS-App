import SwiftUI

extension ShareView {
    struct ShareAsFileButton: View {
        var action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                VStack(spacing: 12) {
                    Image("ShareAsFile")
                    Text("Export File")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.a1)
                }
            }
        }
    }
}
