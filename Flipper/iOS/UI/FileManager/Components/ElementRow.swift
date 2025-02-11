import Core

import SwiftUI

extension FileManagerView.FileManagerListing {
    struct ElementRowGrid: View {
        let element: ExtendedElement

        let onSelect: () -> Void
        let onTap: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Icon(for: element)
                    Spacer()
                    Action(onTap: onSelect)
                }
                Title(for: element)
            }
            .padding(12)
            .background(Color.groupedBackground)
            .cornerRadius(12)
            .onTapGesture { onTap() }
        }
    }

    struct ElementRowList: View {
        let element: ExtendedElement

        let onSelect: () -> Void
        let onDelete: () -> Void
        let onTap: () -> Void

        var body: some View {
            HStack(spacing: 12) {
                Icon(for: element)
                Title(for: element)
                Spacer()
                Action(onTap: onSelect)
            }
            .padding(12)
            .background(Color.groupedBackground)
            .modifier(SwipeToDeleteModifier(onDelete: onDelete, onTap: onTap))
        }
    }
}

fileprivate extension FileManagerView.FileManagerListing {
    struct Icon: View {
        let element: ExtendedElement

        private var image: Image {
            switch element.type {
            case .directory:
                return .init("Folder")
            case .file:
                do {
                    let item = try ArchiveItem.Kind(filename: element.name)
                    return item.icon
                } catch {
                    return Image("File")
                }
            }
        }

        init(for element: ExtendedElement) {
            self.element = element
        }

        var body: some View {
            image
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24)
                .foregroundColor(.primary)
        }
    }

    struct Title: View {
        let element: ExtendedElement

        init(for element: ExtendedElement) {
            self.element = element
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(element.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if case let .file(file) = element.type {
                    Text(file.size.hr)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.black30)
                }
            }
            .frame(height: 32)
        }
    }

    struct Action: View {
        let onTap: () -> Void

        var body: some View {
            Image(systemName: "ellipsis")
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.black30)
                .frame(width: 20)
                .padding([.vertical, .leading], 12)
                .contentShape(Rectangle())
                .onTapGesture { onTap() }
        }
    }
}

fileprivate extension FileManagerView.FileManagerListing {
    struct SwipeToDeleteModifier: ViewModifier {
        @State private var offset: CGFloat = 0
        @GestureState private var isDragging: Bool = false

        let onDelete: () -> Void
        let onTap: () -> Void

        private var iconSize: Double { 24 }
        private var iconPadding: Double { 16 }

        private var deleteThreshold: CGFloat { -(iconSize + iconPadding * 2) }
        private var fullDeleteThreshold: CGFloat { -120 }

        private var delay: Double { 0.5 }
        private var animation: Animation { .easeOut(duration: delay) }

        private var maxRadius: CGFloat { 12 }
        private var radius: CGFloat {
            let progress = min(1, abs(offset) / abs(deleteThreshold))
            return maxRadius * (1 - progress)
        }

        func body(content: Content) -> some View {
            ZStack {
                Rectangle()
                    .foregroundColor(.red.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        Image("Delete")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.red)
                            .frame(width: iconSize, height: iconSize)
                            .padding(16)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(animation) {
                                    offset = 0
                                }
                                onDelete()
                            },
                        alignment: .trailing
                    )

                content
                    .clipShape(
                        .rect(
                            topLeadingRadius: maxRadius,
                            bottomLeadingRadius: maxRadius,
                            bottomTrailingRadius: radius,
                            topTrailingRadius: radius
                        )
                    )
                    .offset(x: offset)
                    .simultaneousGesture(
                        DragGesture(
                            minimumDistance: 50,
                            coordinateSpace: .local
                        )
                        .updating($isDragging) { _, state, _ in
                            state = true
                        }
                        .onChanged { value in
                            let translation = value.translation.width
                            if translation <= 0 {
                                offset = translation
                            }
                        }
                        .onEnded { value in
                            let translation = value.translation.width

                            if translation <= fullDeleteThreshold {
                                withAnimation(animation) {
                                    offset = -UIScreen.main.bounds.width
                                }

                                Task { @MainActor in
                                    try await Task.sleep(seconds: delay)
                                    onDelete()

                                    withAnimation(animation) {
                                        offset = 0
                                    }
                                }
                            } else if translation <= deleteThreshold {
                                withAnimation(animation) {
                                    offset = deleteThreshold
                                }
                            } else {
                                withAnimation(animation) {
                                    offset = 0
                                }
                            }
                        }
                    )
                    .onTapGesture {
                        if offset != 0 {
                            withAnimation(animation) {
                                offset = 0
                            }
                        } else {
                            onTap()
                        }
                    }
            }
        }
    }
}
