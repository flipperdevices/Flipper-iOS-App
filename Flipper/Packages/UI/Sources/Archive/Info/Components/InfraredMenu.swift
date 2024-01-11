import SwiftUI

struct InfraredMenu: View {
    @Binding var isPresented: Bool
    let onShare: () -> Void
    let onHowTo: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 0) {
                InfraredMenuItem(
                    title: "Share Remote",
                    image: "Share"
                ) {
                    isPresented = false
                    onShare()
                }
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
                .padding(12)

                Divider()
                    .padding(0)

                InfraredMenuItem(
                    title: "Delete",
                    image: "Delete",
                    color: .red
                ) {
                    isPresented = false
                    onDelete()
                }
                .padding(12)
            }
        }
        .frame(width: 220)
    }

    struct InfraredMenuItem: View {
        let title: String
        let image: String
        let color: Color
        let action: () -> Void

        init(
            title: String,
            image: String,
            color: Color = .primary,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.image = image
            self.color = color
            self.action = action
        }

        var body: some View {
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(image)
                        .renderingMode(.template)
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(color)
            }
        }
    }
}
