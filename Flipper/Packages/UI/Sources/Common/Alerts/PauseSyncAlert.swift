import SwiftUI

struct PauseSyncAlert: View {
    @Binding var isPresented: Bool
    var onAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("Pause Synchronization?")
                    .font(.system(size: 14, weight: .bold))

                Text(
                    "This feature can't be used during device " +
                    "synchronization. Wait for sync to finish or pause it."
                )
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
                .padding(.horizontal, 12)
            }
            .padding(.top, 25)

            AlertButtons(
                isPresented: $isPresented,
                text: "Pause & Proceed",
                cancel: "Cancel"
            ) {
                onAction()
            }
        }
    }
}
