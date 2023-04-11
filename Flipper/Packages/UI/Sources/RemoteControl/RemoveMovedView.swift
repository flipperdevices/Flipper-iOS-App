import SwiftUI

struct RemoteMovedView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Image("RemoteMoved")
                .resizable()
                .scaledToFit()

            Text("New Remote Control")
                .font(.system(size: 14, weight: .medium))
                .padding(.top, 24)

            Text("We’ve improved this feature and moved \nit to the Hub tab")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
                .padding(.top, 4)
        }
        .padding(24)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Remote Control")
            }
        }
    }
}
