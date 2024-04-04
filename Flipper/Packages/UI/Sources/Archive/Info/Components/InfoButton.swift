import SwiftUI

struct InfoButton: View {
    @Environment(\.isEnabled) private var isEnabled

    let image: String
    let title: String
    let action: () -> Void
    let role: ButtonRole?

    init(
        image: String,
        title: String,
        action: @escaping () -> Void,
        role: ButtonRole? = nil
    ) {
        self.image = image
        self.title = title
        self.action = action
        self.role = role
    }

    var color: Color {
        switch (role, isEnabled) {
        case (.destructive, true):
            return .red
        case (.destructive, false):
            return .red.opacity(0.5)
        case (_, true):
            return .primary
        case (_, false):
            return .emulateDisabled
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(image)
                    .renderingMode(.template)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(minWidth: 44, minHeight: 44)
            .padding(.trailing, 44)
        }
        .foregroundColor(color)
    }
}
