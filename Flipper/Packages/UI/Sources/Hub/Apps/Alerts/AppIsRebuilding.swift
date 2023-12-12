import Core
import SwiftUI

struct AppIsRebuildingAlert: View {
    @Binding var isPresented: Bool
    let application: Applications.ApplicationInfo
    let category: Applications.Category?

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
                Text("App is Rebuilding")
                    .font(.system(size: 14, weight: .bold))

                Text(
                    "A new app version is rebuilding on the server. " +
                    "Please wait, it can take some time."
                )
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
            }
            .padding(.horizontal, 12)

            Button {
                isPresented = false
            } label: {
                Text("Got It")
                    .frame(height: 41)
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .background(Color.a2)
                    .cornerRadius(30)
            }
        }
    }
}
