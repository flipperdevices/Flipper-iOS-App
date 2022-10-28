import SwiftUI

struct CancelAttackAlert: View {
    @Binding var isPresented: Bool
    var onAbort: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("Abort Keys Сalculation?")
                    .font(.system(size: 14, weight: .bold))
                    .padding(.top, 25)

                Text("Exit the current app on Flipper to use this feature")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
            }

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
