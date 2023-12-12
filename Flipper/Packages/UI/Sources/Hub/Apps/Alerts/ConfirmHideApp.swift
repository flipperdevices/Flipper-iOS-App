import Core
import SwiftUI

struct ConfirmHideAppAlert: View {
    @Binding var isPresented: Bool
    let application: Applications.ApplicationInfo
    let category: Applications.Category?

    var onAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .center) {
                AppRow.IconNameCategory(
                    application: application,
                    category: category
                )
                .padding(16)
            }
            .frame(maxWidth: .infinity)
            .background(Color("AppAlertBackground"))
            .cornerRadius(12)
            .padding(.top, 24)

            VStack(spacing: 4) {
                Text("Hide this App?")
                    .font(.system(size: 14, weight: .bold))

                Text("You won’t see this app again")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black40)
            }

            AlertButtons(
                isPresented: $isPresented,
                text: "Hide",
                cancel: "Cancel",
                isDestructive: true
            ) {
                onAction()
            }
        }
    }
}
