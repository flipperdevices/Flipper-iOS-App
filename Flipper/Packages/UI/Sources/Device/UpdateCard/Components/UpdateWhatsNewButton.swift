import Core
import SwiftUI

struct UpdateWhatsNewButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showChangelog: Bool

    var contentColor: Color {
        switch colorScheme {
        case .light: return .black40
        default: return .black30
        }
    }

    var borderColor: Color {
        switch colorScheme {
        case .light: return .black8
        default: return .black80
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image("WhatsNew")
                .renderingMode(.template)
                .resizable()
                .frame(width: 12, height: 12)

            Text("What’s New")
                .font(.system(size: 12))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .foregroundColor(contentColor)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(borderColor, lineWidth: 1)
        )
        .onTapGesture { showChangelog = true }
    }
}
