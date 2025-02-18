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
        @State private var offset: CGFloat = 0

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
                    .opacity(offset == 0 ? 1 : 0)
                    .animation(nil, value: offset)
            }
            .padding(12)
            .background(Color.groupedBackground)
            .modifier(
                SwipeToDeleteModifier(
                    offset: $offset,
                    onDelete: onDelete,
                    onTap: onTap
                )
            )
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
        @Binding var offset: CGFloat

        let onDelete: () -> Void
        let onTap: () -> Void

        private var iconSize: Double { 24 }
        private var iconPadding: Double { 16 }

        private var deleteThreshold: CGFloat { -(iconSize + iconPadding * 2) }
        private var fullDeleteThreshold: CGFloat { -160 }

        private var delay: Double { 0.5 }
        private var animation: Animation { .easeOut(duration: delay) }

        private var maxRadius: CGFloat { 12 }
        private var radius: CGFloat {
            let progress = min(1, abs(offset) / abs(deleteThreshold))
            return maxRadius * (1 - progress)
        }

        func body(content: Content) -> some View {
            ZStack(alignment: .trailing) {
                Image("Delete")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.red)
                    .frame(width: iconSize, height: iconSize)
                    .padding(16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        deleteAction()
                    }

                content
                    .clipShape(
                        .rect(
                            topLeadingRadius: maxRadius,
                            bottomLeadingRadius: maxRadius,
                            bottomTrailingRadius: radius,
                            topTrailingRadius: radius
                        )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.red.opacity(0.1))
                            .offset(x: -offset)
                    )
                    .offset(x: offset)
                    .simultaneousGesture(
                        DragGesture(
                            minimumDistance: 10,
                            coordinateSpace: .local
                        )
                        .onChanged { value in
                            let translation = value.translation.width

                            if value.isHorizontal {
                                if translation <= 0 {
                                    withAnimation(.interactiveSpring()) {
                                        offset = translation
                                    }
                                }
                            }
                        }
                        .onEnded { value in
                            let translation = value.translation.width

                            if value.isHorizontal {
                                if translation <= fullDeleteThreshold {
                                    deleteAction()
                                } else if translation <= deleteThreshold {
                                    withAnimation(animation) {
                                        offset = deleteThreshold
                                    }
                                } else {
                                    closeAction()
                                }
                            } else {
                                withAnimation(.interactiveSpring()) {
                                    offset = 0
                                }
                            }
                        }
                    )
                    .onTapGesture {
                        if offset != 0 {
                            closeAction()
                        } else {
                            onTap()
                        }
                    }
            }
        }

        private func closeAction() {
            withAnimation(animation) {
                offset = 0
            }
        }

        private func deleteAction() {
            Task { @MainActor in
                withAnimation(animation) {
                    offset = -UIScreen.main.bounds.width
                }
                try await Task.sleep(seconds: delay)
                onDelete()

                withAnimation(animation) {
                    offset = 0
                }
            }
        }
    }
}

fileprivate extension DragGesture.Value {
    var isHorizontal: Bool {
        let horizontalAmount = abs(translation.width)
        let verticalAmount = abs(translation.height)
        return horizontalAmount > verticalAmount
    }
}
