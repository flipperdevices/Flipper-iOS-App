import SwiftUI

struct InfraredSignalInstruction: View {
    @Environment(\.colorScheme) private var colorScheme

    private var titleColor: Color {
        switch colorScheme {
        case .light: .black60
        default: .black20
        }
    }

    private var descriptionColor: Color {
        switch colorScheme {
        case .light: .black30
        default: .black40
        }
    }

    private var borderColor: Color {
        switch colorScheme {
        case .light: .black12
        default: .black80
        }
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(
                    """
                    Let's test some buttons to find the
                    right remote:
                    """
                )
                .foregroundColor(titleColor)
                .font(.system(size: 16, weight: .bold))

                Image("InfraredHowToSignal")

                Text(
                    """
                    1. Point your Flipper Zero at the device.
                    2. Tap the button below.
                    """
                )
                .foregroundColor(descriptionColor)
                .font(.system(size: 14, weight: .medium))
            }
            .padding(12)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )

            Image("ArrowDown")
                .renderingMode(.template)
                .foregroundColor(borderColor)
        }
    }
}

#Preview {
    InfraredSignalInstruction()
}
