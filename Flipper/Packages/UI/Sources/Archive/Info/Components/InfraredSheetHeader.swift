import SwiftUI

struct InfraredSheetHeader: View {
    let title: String
    let description: String?
    let onCancel: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void

    @State private var showHowToUse: Bool = false
    @State private var showInfraredOption = false
    @State private var infraredOptionOffset: Double = .zero

    var body: some View {
        NavBar(
            leading: {
                NavBarButton(action: { showInfraredOption = true } ) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .medium))
                        .overlay(GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    let frame = proxy.frame(in: .global)
                                    infraredOptionOffset = frame.maxY
                                }
                        })
                }
            },
            principal: {
                Title(title, description: description)
            },
            trailing: {
                NavBarButton(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                }
            }
        )
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .alert(isPresented: $showHowToUse) {
            InfraredHowToUseDialog(isPresented: $showHowToUse)
        }
        .popup(isPresented: $showInfraredOption) {
            Card {
                VStack(alignment: .leading, spacing: 0) {
                    InfraredMenuItem(
                        title: "Share Remote",
                        image: "Share"
                    ) {
                        showInfraredOption = false
                        onShare()
                    }
                    .padding(12)

                    Divider()
                        .padding(0)

                    InfraredMenuItem(
                        title: "How to Use",
                        image: "HowTo"
                    ) {
                        showInfraredOption = false
                        showHowToUse = true
                    }
                    .padding(12)

                    Divider()
                        .padding(0)

                    InfraredMenuItem(
                        title: "Delete",
                        image: "Delete",
                        color: .red
                    ) {
                        showInfraredOption = false
                        onDelete()
                    }
                    .padding(12)
                }
            }
            .frame(width: 220)
            .offset(y: infraredOptionOffset)
            .padding(.leading, 32)
        }
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
