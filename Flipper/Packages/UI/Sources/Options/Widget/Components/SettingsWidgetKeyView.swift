import SwiftUI

struct SettingsWidgetKeyView: View {
    let key: WidgetKey

    var onDelete: () -> Void

    var color: Color {
        switch key.kind {
        case .subghz: return .a1
        case .nfc, .rfid: return .a2
        default: return .clear
        }
    }

    var label: String {
        switch key.kind {
        case .subghz: return "Send"
        case .nfc, .rfid: return "Emulate"
        default: return ""
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 20, height: 20)
                }

                VStack(spacing: 2) {
                    key.kind.icon
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                        .frame(width: 20, height: 20)

                    Text(key.name.value)
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
            }

            HStack {
                Spacer()
                Text(label)
                    .font(.born2bSportyV2(size: 20))
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(height: 45)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            )
        }
    }
}
