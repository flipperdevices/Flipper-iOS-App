import SwiftUI

extension ShareView {
    struct CantConnectError: View {
        var action: () -> Void

        var body: some View {
            VStack(spacing: 2) {
                Image("SharingCantConnect")
                    .resizable()
                    .frame(width: 84, height: 48)
                Text("Can't Connect to the Server")
                    .font(.system(size: 14, weight: .medium))
                Text("Unable to share this link")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black40)
                Button {
                    action()
                } label: {
                    Text("Retry")
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
    }
}
