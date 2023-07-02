import Core
import SwiftUI

struct ConfirmDeleteAppAlert: View {
    @Binding var isPresented: Bool
    let application: Applications.Application

    var onAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .center) {
                IconNameCategory(
                    application: application,
                    size: .small
                )
                .padding(16)
            }
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.14, green: 0.14, blue: 0.14))
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
