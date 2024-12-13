import Core

import SwiftUI

extension FileManagerView.FileManagerListing {
    struct FileManagerElements: View {
        let elements: [ExtendedElement]
        let displayType: DisplayType

        let onTap: (ExtendedElement) -> Void
        let onDelete: (ExtendedElement) -> Void
        let onAction: (ExtendedElement) -> Void

        private let columns = [GridItem(.flexible()), GridItem(.flexible())]

        var body: some View {
            Group {
                switch displayType {
                case .list:
                    ForEach(elements) { element in
                        ElementRow(
                            element: element,
                            type: displayType,
                            onAction: { onAction(element) }
                        )
                        .onTapGesture { onTap(element) }
                        .swipeActions {
                            Button(role: .destructive) {
                                onDelete(element)
                            } label: {
                                Image("Delete")
                                    .foregroundColor(.red)
                            }
                            .tint(.red.opacity(0.1))
                        }
                    }
                case .grid:
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(elements) { element in
                            ElementRow(
                                element: element,
                                type: displayType,
                                onAction: { onAction(element) }
                            )
                            .onTapGesture { onTap(element) }
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(
                .init(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
            )
            .listRowBackground(Color.clear)
        }
    }
}
