import Core

import SwiftUI

extension FileManagerView.FileManagerListing {
    struct FileManagerElements: View {
        let elements: [ExtendedElement]
        let displayType: FileManagerSettings.DisplayType

        let onTap: (ExtendedElement) -> Void
        let onDelete: (ExtendedElement) -> Void
        let onSelect: (ExtendedElement) -> Void

        private let columns = [GridItem(.flexible()), GridItem(.flexible())]

        var body: some View {
            switch displayType {
            case .list:
                LazyVStack(spacing: 12) {
                    ForEach(elements) { element in
                        ElementRow(
                            element: element,
                            type: displayType,
                            onAction: { onSelect(element) }
                        )
                        .onTapGesture { onTap(element) }
                    }
                }
            case .grid:
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(elements) { element in
                        ElementRow(
                            element: element,
                            type: displayType,
                            onAction: { onSelect(element) }
                        )
                        .onTapGesture { onTap(element) }
                    }
                }
            }
        }
    }
}
