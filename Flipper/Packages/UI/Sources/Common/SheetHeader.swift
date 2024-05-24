import SwiftUI

struct SheetHeader: View {
    let title: String
    let description: String?
    let onCancel: () -> Void

    init(
        title: String,
        description: String? = nil,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.onCancel = onCancel
    }

    var body: some View {
        NavBar(
            leading: {
                EmptyView()
            },
            principal: {
                Title(title, description: description)
            },
            trailing: {
                CloseButton(action: onCancel)
            }
        )
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}
