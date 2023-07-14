import Core
import SwiftUI

struct ConfirmDeleteAppAlert: View {
    @Binding var isPresented: Bool
    let application: Applications.ApplicationInfo

    var onAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .center) {
                AppRow.IconNameCategory(application: application)
                    .padding(16)
            }
            .frame(maxWidth: .infinity)
            .background(Color("AppAlertBackground"))
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
