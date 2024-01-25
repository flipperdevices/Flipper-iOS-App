import Core
import SwiftUI

struct InfraredInfoView: View {
    let onShare: () -> Void
    let onDelete: () -> Void

    @Binding var current: ArchiveItem
    @Binding var isEditing: Bool

    @State private var showHowToUse: Bool = false
    @State private var showInfraredOption = false
    @State private var showEditor = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CardView(
                    item: $current,
                    isEditing: $isEditing,
                    kind: .existing
                )
                .padding(.top, 6)
                .padding(.horizontal, 24)

                EmulateView(item: current)
                    .padding(.bottom, 12)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }

            PrincipalToolbarItems {
                Title(current.name.value, description: "Remote Info")
            }

            TrailingToolbarItems {
                InfraredMenuButton(
                    onShare: onShare,
                    onDelete: onDelete,
                    onEdit: openEditor
                )
            }
        }
        .fullScreenCover(isPresented: $showEditor) {
            InfraredEditorView(item: $current)
        }
    }

    private func openEditor() {
        showEditor = true
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
