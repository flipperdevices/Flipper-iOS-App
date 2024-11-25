import Core
import Peripheral

import SwiftUI

extension FileManagerView.FileManagerListing {
    struct ElementRow: View {
        let element: Element
        let type: DisplayType

        let onAction: () -> Void

        var body: some View {
            Group {
                switch type {
                case .grid:
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Icon(for: element)
                            Spacer()
                            Action(onTap: onAction)
                        }
                        Title(for: element)
                    }
                case .list:
                    HStack(spacing: 12) {
                        Icon(for: element)
                        Title(for: element)
                        Spacer()
                        Action(onTap: onAction)
                    }
                }
            }
            .padding(12)
            .background(Color.groupedBackground)
            .cornerRadius(12)
        }
    }
}

fileprivate extension FileManagerView.FileManagerListing.ElementRow {
    struct Icon: View {
        let element: Element

        private var image: Image {
            switch element {
            case .directory:
                return .init("Folder")
            case .file:
                if let item = try? ArchiveItem.Kind(filename: element.name) {
                    return item.icon
                } else {
                    return .init("File")
                }
            }
        }

        init(for element: Element) {
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
        let element: Element

        init(for element: Element) {
            self.element = element
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(element.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if case let .file(file) = element {
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
