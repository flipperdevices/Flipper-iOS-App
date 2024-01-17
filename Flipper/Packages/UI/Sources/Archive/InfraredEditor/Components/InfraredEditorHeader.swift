import SwiftUI

extension InfraredEditorView {
    struct Header: View {
        let title: String
        let description: String
        let canSave: Bool
        let onCancel: () -> Void
        let onSave: () -> Void

        var body: some View {
            NavBar(
                leading: {
                    NavBarButton {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.primary)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 14)
                    }
                },
                principal: {
                    Title(title, description: description)
                },
                trailing: {
                    NavBarButton {
                        onSave()
                    } label: {
                        Text("Save")
                            .foregroundColor(canSave ? .a2 : .black40)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 14)
                    }
                    .disabled(!canSave)
                }
            )
        }
    }
}
