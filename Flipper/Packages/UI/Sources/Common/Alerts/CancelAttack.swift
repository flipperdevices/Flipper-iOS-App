import SwiftUI

struct CancelAttackAlert: View {
    @Binding var isPresented: Bool
    var onAbort: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("Abort Keys Сalculation?")
                    .font(.system(size: 14, weight: .bold))

                Text("You can restart it later")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
                    .padding(.horizontal, 12)
            }
            .padding(.top, 25)

            // TODO: move to view builder

            VStack(spacing: 14) {
                Divider()

                Button {
                    onAbort()
                    isPresented = false
                } label: {
                    Text("Abort")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.a2)
                }

                Divider()

                Button {
                    isPresented = false
                } label: {
                    Text("Continue")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
        }
    }
}
