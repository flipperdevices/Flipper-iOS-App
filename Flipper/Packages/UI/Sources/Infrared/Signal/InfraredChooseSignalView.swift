import Core
import SwiftUI

extension InfraredView {
    struct InfraredChooseSignalView: View {
        let button: InfraredButtonData
        let state: InfraredLayoutState

        let onStartEmulate: (InfraredKeyID) -> Void
        let onSkip: () -> Void

        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                InfraredSignalInstruction()

                InfraredButtonTypeView(data: button)
                    .frame(width: 60, height: 60)
                    .environment(\.layoutState, state)
                    .environment(\.emulateAction, onStartEmulate)
                    .padding(.top, 12)

                Spacer()

                switch state {
                case .default:
                    Text("Skip This Button")
                        .foregroundColor(Color.a2)
                        .font(.system(size: 16, weight: .medium))
                        .onTapGesture { onSkip() }
                default:
                    AnimatedPlaceholder()
                        .frame(width: 120, height: 24)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 24)
        }
    }
}
