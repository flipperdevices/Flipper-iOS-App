import SwiftUI

extension NFCEditorView {
    struct Header: View {
        let title: String
        let description: String?
        let onCancel: () -> Void
        let onSave: () -> Void
        let onSaveAs: () -> Void

        var body: some View {
            NavBar(
                leading: {
                    NavBarButton {
                        onCancel()
                    } label: {
                        Text("Close")
                            .foregroundColor(.primary)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 14)
                    }
                },
                principal: {
                    Title(title, description: description)
                },
                trailing: {
                    NavBarMenu {
                        Button("Save", action: onSave)
                        Button("Save Dump as...", action: onSaveAs)
                    } label: {
                        Text("Save")
                            .foregroundColor(.primary)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 14)
                    }
                }
            )
        }
    }
}
