import SwiftUI
import MarkdownUI
import Peripheral

struct AttackConnectionError: View {
    let fliperColor: FlipperColor

    var instructions: [String] = [
        "Check Bluetooth connection with Flipper",
        "Make sure Flipper is Turned On",
        "If Flipper doesn’t respond, reboot it and connect to " +
        "the app via Bluetooth",
        "Restart **Mfkey32 (Detect Reader)**"
    ]
    
    var body: some View {
        VStack(spacing: 18) {
            Text("Flipper is not Connected")
                .font(.system(size: 18, weight: .bold))

            VStack(spacing: 26) {
                Image(
                    fliperColor == .white
                        ? "FlipperDeadWhite"
                        : "FlipperDeadBlack"
                )
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.leading, 10)
                .padding(.trailing, 24)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(instructions.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 0) {
                            Text("\(index + 1). ")
                            Markdown(instructions[index])
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .font(.system(size: 16))
                    .opacity(0.5)
                }
            }
        }
    }
}
