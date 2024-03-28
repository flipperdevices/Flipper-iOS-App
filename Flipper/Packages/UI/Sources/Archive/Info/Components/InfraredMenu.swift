import Core
import SwiftUI

struct InfraredMenu: View {
    @Binding var isPresented: Bool
    let onShare: () -> Void
    let onHowTo: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void

    @EnvironmentObject private var emulate: Emulate

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
                .foregroundColor(
                    emulate.inProgress 
                    ? .emulateDisabled
                    : .primary
                )
                .disabled(emulate.inProgress)
                .padding(12)

                Divider()
                    .padding(0)

                InfraredMenuItem(
                    title: "Share Remote",
                    image: "Share"
                ) {
                    isPresented = false
                    onShare()
                }
                .foregroundColor(.primary)
                .padding(12)

                Divider()
                    .padding(0)

                InfraredMenuItem(
                    title: "How to Use",
                    image: "HowTo"
                ) {
                    isPresented = false
                    onHowTo()
                }
                .foregroundColor(.primary)
                .padding(12)

                Divider()
                    .padding(0)

                InfraredMenuItem(
                    title: "Delete",
                    image: "Delete"
                ) {
                    isPresented = false
                    onDelete()
                }
                .foregroundColor(.red)
                .padding(12)
            }
        }
        .frame(width: 220)
    }

    struct InfraredMenuItem: View {
        let title: String
        let image: String
        let action: () -> Void

        init(
            title: String,
            image: String,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.image = image
            self.action = action
        }

        var body: some View {
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(image)
                        .renderingMode(.template)
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                }
            }
        }
    }
}
