import Core

import SwiftUI

extension FileManagerView.FileManagerListing {
    struct SelectedElementSheet: View {
        @Environment(\.colorScheme) var colorScheme

        let element: ExtendedElement

        let onExport: (ExtendedElement) -> Void
        let onDelete: (ExtendedElement) -> Void

        private var backgroundColor: Color {
            colorScheme == .light ? .white : .black88
        }

        private var type: String {
            switch element.type {
            case .directory: "Folder"
            case .file: "File"
            }
        }

        private var isDirectory: Bool {
            return if case .directory = element.type {
                true
            } else {
                false
            }
        }

        var body: some View {
            VStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text(type)
                        .font(.system(size: 14, weight: .medium))

                    Text(element.name)
                        .font(.system(size: 14, weight: .bold))
                }

                Option(
                    image: "Share",
                    title: "Export"
                ) {
                    onExport(element)
                }
                .disabled(isDirectory)
                .foregroundColor(.primary)

                Option(
                    image: "Delete",
                    title: "Delete"
                ) {
                    onDelete(element)
                }
                .foregroundColor(.red)
            }
            .padding(.horizontal, 14)
            .background(backgroundColor)
            .presentationDragIndicator(.visible)
            .presentationDetents([.height(200)])
            .pickerStyle(.segmented)
        }
    }
}

fileprivate extension FileManagerView.FileManagerListing.SelectedElementSheet {
    struct Option: View {
        @Environment(\.isEnabled) private var isEnabled

        let image: String
        let title: String
        let action: () -> Void

        var body: some View {
            HStack(spacing: 8) {
                Image(image)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.system(size: 14, weight: .medium))

                Spacer()
            }
            .opacity(isEnabled ? 1 : 0.4)
            .padding(12)
            .onTapGesture { action() }
        }
    }
}
