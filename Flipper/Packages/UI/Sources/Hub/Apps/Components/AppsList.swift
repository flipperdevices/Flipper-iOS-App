import Core
import SwiftUI

struct AppList: View {
    @EnvironmentObject var model: Applications
    let applications: [Applications.ApplicationInfo]
    let isInstalled: Bool

    init(
        applications: [Applications.ApplicationInfo],
        isInstalled: Bool = false
    ) {
        self.applications = applications
        self.isInstalled = isInstalled
    }

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(applications) { application in
                NavigationLink {
                    AppView(alias: application.alias)
                        .environmentObject(model)
                } label: {
                    AppRow(
                        application: application,
                        isInstalled: isInstalled
                    )
                }
                .foregroundColor(.primary)

                if application.id != applications.last?.id {
                    Divider()
                        .padding(.horizontal, 14)
                        .foregroundColor(.black4)
                }
            }
        }
    }
}
