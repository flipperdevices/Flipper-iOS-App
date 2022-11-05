import SwiftUI

struct SheetEditHeader: View {
    let title: String
    let description: String?
    let onSave: @MainActor () -> Void
    let onCancel: @MainActor () -> Void

    init(
        title: String,
        description: String? = nil,
        onSave: @escaping @MainActor () -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.description = description
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavBar(
            leading: {
                NavBarButton {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 8)
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
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 8)
                }
            }
        )
        .padding(8)
    }
}
