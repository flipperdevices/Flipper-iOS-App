import Core
import SwiftUI

struct ConfirmDeleteAppAlert: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var isPresented: Bool
    let application: Applications.Application

    var onAction: () -> Void

    var color: Color {
        colorScheme == .light
            ? .init(red: 0.97, green: 0.97, blue: 0.97)
            : .init(red: 0.14, green: 0.14, blue: 0.14)
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .center) {
                AppRow.IconNameCategory(application: application)
                    .padding(16)
            }
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(12)
            .padding(.top, 24)

            Text("Delete this App?")
                .font(.system(size: 14, weight: .bold))

            AlertButtons(
                isPresented: $isPresented,
                text: "Delete",
                cancel: "Cancel",
                isDestructive: true
            ) {
                onAction()
            }
        }
    }
}
