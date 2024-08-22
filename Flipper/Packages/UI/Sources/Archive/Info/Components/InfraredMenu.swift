import Core
import SwiftUI

struct InfraredMenu: View {
    @EnvironmentObject var emulate: Emulate

    @Binding var isPresented: Bool
    let onShare: () -> Void
    let onHowTo: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void

    var isEditable: Bool {
        !emulate.inProgress
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 0) {
                InfraredMenuItem(
                    title: "Edit Remote",
                    image: "InfraredEditor"
                ) {
                    isPresented = false
                    onEdit()
                }
                .disabled(!isEditable)

                Divider()
                    .padding(0)

                InfraredMenuItem(
                    title: "Share Remote",
                    image: "Share"
                ) {
                    isPresented = false
                    onShare()
                }

                Divider()
                    .padding(0)

                InfraredMenuItem(
                    title: "How to Use",
                    image: "HowTo"
                ) {
                    isPresented = false
                    onHowTo()
                }

                Divider()
                    .padding(0)

                InfraredMenuItem(
                    title: "Delete",
                    image: "Delete",
                    role: .destructive
                ) {
                    isPresented = false
                    onDelete()
                }
                .disabled(!isEditable)
            }
        }
        .frame(width: 220)
    }
}

struct InfraredMenuItem: View {
    @Environment(\.isEnabled) private var isEnabled

    let title: String
    let image: String
    let action: () -> Void
    let role: ButtonRole?
    let imageColor: Color?

    init(
        title: String,
        image: String,
        role: ButtonRole? = nil,
        imageColor: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.action = action
        self.imageColor = imageColor
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
                    .foregroundColor(imageColor ?? color)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                Spacer()
            }
        }
        .padding(12)
    }
}
