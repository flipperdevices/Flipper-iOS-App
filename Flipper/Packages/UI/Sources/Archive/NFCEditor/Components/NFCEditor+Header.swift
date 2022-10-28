import SwiftUI

extension NFCEditorView {
    struct Header: View {
        let title: String
        let description: String?
        let onCancel: () -> Void
        let onSave: () -> Void
        let onSaveAs: () -> Void

        var body: some View {
            HStack {
                Button {
                    onCancel()
                } label: {
                    Text("Close")
                        .foregroundColor(.primary)
                        .font(.system(size: 14, weight: .medium))
                }

                Spacer()

                VStack(spacing: 0) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                    if let description = description {
                        Text(description)
                            .font(.system(size: 12, weight: .medium))
                    }
                }

                Spacer()

                Menu {
                    Button("Save", action: onSave)
                    Button("Save Dump as...", action: onSaveAs)
                } label: {
                    Text(" Save")
                        .foregroundColor(.primary)
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .padding(.horizontal, 19)
            .padding(.top, 17)
            .padding(.bottom, 6)
        }
    }
}
