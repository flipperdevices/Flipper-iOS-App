import Core
import SwiftUI

struct AppsOutdatedAppAlert: View {
    @Binding var isPresented: Bool
    let application: Applications.Application
    let category: Applications.Category?

    var action: () -> Void

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
                Text("Outdated App")
                    .font(.system(size: 14, weight: .bold))

                Text(
                    "Contact the developer on GitHub to request " +
                    "further app support"
                )
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
            }
            .padding(.horizontal, 12)

            Button {
                action()
                isPresented = false
            } label: {
                HStack(spacing: 8) {
                    Image("GitHubButton")

                    Text("Go To GitHub")
                        .underline()
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(height: 41)
                .frame(maxWidth: .infinity)
                .background(Color.a2)
                .cornerRadius(30)
            }
        }
    }
}
